/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

data "google_project" "project_number" {
  project_id = var.project_id
}

data "google_secret_manager_secret_version" "app-suffix" {
  secret = "app-suffix"
  project = var.project_id
}

locals{
  project_number = data.google_project.project_number.number
  env = ["dev", "staging", "prod"]
}

// Enable any extra APIs that are required for the admin project
module "project-service-cloudresourcemanager" {
  source  = "git::YOUR_GITHUB_URL/YOUR_GITHUB_ORG/terraform-modules//project-factory/modules/project_services"
  project_id = var.project_id
  activate_apis = [
    "artifactregistry.googleapis.com",
    "clouddeploy.googleapis.com",
    "container.googleapis.com"
  ]
}

// Create GitHub webhook to invoke Cloud Build trigger
module "app-web-hook" {
  count  = var.trigger_type == "webhook" ? 1 : 0
  source = "git::YOUR_GITHUB_URL/YOUR_GITHUB_ORG/terraform-modules//webhooks/application"

  app_name        = var.application_name
  project_number  = local.project_number
  app_repo_name   = var.application_name
  project_id      = var.project_id
  service_account = var.cloudbuild_service_account
  secret_project_id = var.secret_project_id
}

//Create GitHub trigger to invoke Cloud Build trigger
module "app-github-trigger" {
  count  = var.trigger_type == "github" ? 1 : 0
  source = "git::YOUR_GITHUB_URL/YOUR_GITHUB_ORG/terraform-modules//github-triggers/application"

  project_id      = var.project_id
  service_account = var.cloudbuild_service_account
  github_org      = var.org_name_to_clone_template_from
  app_name        = var.application_name
}

module "artifact-registry" {
  source = "git::YOUR_GITHUB_URL/YOUR_GITHUB_ORG/terraform-modules//artifact-registry"

  id          = var.application_name
  project_id  = var.project_id
  location    = var.region
  description = "Artifact registry for ${var.application_name} in ${var.project_id}"

  depends_on = [
    module.project-service-cloudresourcemanager
  ]
}
// Permission Run service agent in app projects to read the artifact repo
resource "google_artifact_registry_repository_iam_member" "ar_permissions" {
  provider      = google-beta
  for_each           = toset(local.env)
  project = var.project_id
  location = var.region
  repository = module.artifact-registry.registry
  role = "roles/artifactregistry.reader"
  member = format("%s:%s-%s@%s","serviceAccount","service",module.create-gcp-project[each.key].project_number,"serverless-robot-prod.iam.gserviceaccount.com")
  depends_on = [ google_service_account.service-identity-sa ]
}

// Create deployment projects for the application
module "create-gcp-project" {
  for_each = toset(local.env)
  source                  = "git::YOUR_GITHUB_URL/YOUR_GITHUB_ORG/terraform-modules.git//project-factory"
  billing_account         = var.billing_account
  name                    = join("-",[var.application_name,each.key,data.google_secret_manager_secret_version.app-suffix.secret_data])
  org_id                  = var.org_id
  folder_id               = var.folder_id
  default_service_account = "keep"
  activate_apis = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudbilling.googleapis.com",
    "run.googleapis.com",
    "compute.googleapis.com",
    "clouddeploy.googleapis.com",
    "container.googleapis.com"
  ]
}

// Create a service identity SA in each application project

resource "google_service_account" "service-identity-sa" {
  for_each     = toset(local.env)
  project      = module.create-gcp-project[each.key].project_id
  account_id   = "${each.key}-si-${var.application_name}"
  display_name = "Service Identity SA for ${each.key} environment"
}

// Allow CloudDeploy SA to impersonate the service identity accounts so it can deploy cloudrun services with them
resource "google_service_account_iam_member" "cd-impersonate-si" {
  for_each           = toset(local.env)
  service_account_id = google_service_account.service-identity-sa[each.key].name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:clouddeploy@${var.project_id}.iam.gserviceaccount.com"
}

// Allow CloudDeploy SA run developer role on the new application projects
resource "google_project_iam_member" "cloud-deploy-roles-cr" {
  for_each     = toset(local.env)
  project      = module.create-gcp-project[each.key].project_id
  role         = "roles/run.developer"
  member       = "serviceAccount:${var.clouddeploy_service_account}"
}
// Allow CloudDeploy SA log writer role on the new application projects
resource "google_project_iam_member" "cloud-deploy-roles-lw" {
  for_each     = toset(local.env)
  project      = module.create-gcp-project[each.key].project_id
  role         = "roles/logging.logWriter"
  member       = "serviceAccount:${var.clouddeploy_service_account}"
}
resource "google_clouddeploy_target" "dev-target" {
  location = var.region
  name     = "dev"
  deploy_parameters = {}
  description       = "dev target"
  annotations = {
    env = "dev"
    app = var.application_name
  }
  execution_configs {
    usages            = ["RENDER", "DEPLOY"]
    execution_timeout = "3600s"
    service_account = var.clouddeploy_service_account
  }
  project          = var.project_id
  require_approval = false

  run {
    location = "projects/${module.create-gcp-project["dev"].project_id}/locations/${var.region}"
  }
  provider = google-beta
  depends_on = [module.project-service-cloudresourcemanager]
}

resource "google_clouddeploy_target" "staging-multi-target" {
  location = var.region
  name     = "staging"
  deploy_parameters = {}
  description       = "staging multi target"
  annotations = {
    env = "staging"
    app = var.application_name
  }
  execution_configs {
    usages            = ["RENDER", "DEPLOY"]
    execution_timeout = "3600s"
    service_account = var.clouddeploy_service_account
  }
  project          = var.project_id
  require_approval = false

  multi_target {
    target_ids = ["staging-${var.region}", "staging-${var.sec_region}"]
  }

  provider = google-beta
  depends_on = [module.project-service-cloudresourcemanager]
}

resource "google_clouddeploy_target" "staging-1-target" {
  location = var.region
  name     = "staging-${var.region}"
  deploy_parameters = {}
  description       = "staging 1 target"
  annotations = {
    env = "staging"
    app = var.application_name
  }
  execution_configs {
    usages            = ["RENDER", "DEPLOY"]
    execution_timeout = "3600s"
    service_account = var.clouddeploy_service_account
  }
  project          = var.project_id
  require_approval = false

  run {
    location = "projects/${module.create-gcp-project["staging"].project_id}/locations/${var.region}"
  }
  provider = google-beta
  depends_on = [module.project-service-cloudresourcemanager]
}

resource "google_clouddeploy_target" "staging-2-target" {
  location = var.region
  name     = "staging-${var.sec_region}"
  deploy_parameters = {}
  description       = "staging 2 target"
  annotations = {
    env = "staging"
    app = var.application_name
  }
  execution_configs {
    usages            = ["RENDER", "DEPLOY"]
    execution_timeout = "3600s"
    service_account = var.clouddeploy_service_account
  }
  project          = var.project_id
  require_approval = false

  run {
    location = "projects/${module.create-gcp-project["staging"].project_id}/locations/${var.sec_region}"
  }
  provider = google-beta
  depends_on = [module.project-service-cloudresourcemanager]
}

resource "google_clouddeploy_target" "prod-multi-target" {
  location = var.region
  name     = "prod"
  deploy_parameters = {}
  description       = "prod multi target"
  annotations = {
    env = "prod"
    app = var.application_name
  }
  execution_configs {
    usages            = ["RENDER", "DEPLOY"]
    execution_timeout = "3600s"
    service_account = var.clouddeploy_service_account
  }
  project          = var.project_id
  require_approval = false

  multi_target {
    target_ids = ["prod-${var.region}", "prod-${var.sec_region}"]
  }

  provider = google-beta
  depends_on = [module.project-service-cloudresourcemanager]
}

resource "google_clouddeploy_target" "prod-1-target" {
  location = var.region
  name     = "prod-${var.region}"
  deploy_parameters = {}
  description       = "prod 1 target"
  annotations = {
    env = "prod"
    app = var.application_name
  }
  execution_configs {
    usages            = ["RENDER", "DEPLOY"]
    execution_timeout = "3600s"
    service_account = var.clouddeploy_service_account
  }
  project          = var.project_id
  require_approval = false

  run {
    location = "projects/${module.create-gcp-project["prod"].project_id}/locations/${var.region}"
  }
  provider = google-beta
  depends_on = [module.project-service-cloudresourcemanager]
}

resource "google_clouddeploy_target" "prod-2-target" {
  location = var.region
  name     = "prod-${var.sec_region}"
  deploy_parameters = {}
  description       = "prod 2 target"
  annotations = {
    env = "prod"
    app = var.application_name
  }
  execution_configs {
    usages            = ["RENDER", "DEPLOY"]
    execution_timeout = "3600s"
    service_account = var.clouddeploy_service_account
  }
  project          = var.project_id
  require_approval = false

  run {
    location = "projects/${module.create-gcp-project["prod"].project_id}/locations/${var.sec_region}"
  }
  provider = google-beta
  depends_on = [module.project-service-cloudresourcemanager]
}

resource "google_clouddeploy_delivery_pipeline" "pipeline" {
  location     = var.region
  name         = var.application_name
  description  = "Deployment pipeline for ${var.application_name}"

  project      = var.project_id

  serial_pipeline {
    stages {
      profiles  = ["dev"]
      target_id = google_clouddeploy_target.dev-target.target_id
    }

    stages {
      profiles  = ["staging"]
      target_id = google_clouddeploy_target.staging-multi-target.target_id
    }

    stages {
      profiles  = ["prod"]
      target_id = google_clouddeploy_target.prod-multi-target.target_id
    }

  }
  depends_on = [module.project-service-cloudresourcemanager]
}