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

data "google_secret_manager_secret_version" "private-pool" {
  secret = "private-pool-dev"
  project = var.secret_project_id
}

locals {
  project_number = data.google_project.project_number.number
}

// Enable any extra APIs that are required for the admin project
// The reason we enable Cloud Deploy API here and not while creating the app via app factory is that if we enable the API in application factory,
// it will cause problems while deleting the app if there are CD resources created in the project. This is because the deletion will trigger TF to
// disable the CD API that it enabled while creating the app and it will fail to do so unless all the CD resources are deleted.
// But enabling the CD API here causes another problem where the Cloud Function tries to provide Workerpool User access to CD service agent
// while creating the application but fails because the CD API is not enabled so the service agent do not exist.
// update 09-15-2019 : We are moving enabling CD API from here to app factory sp the CD service agent get the workerpool user access via Cloud function..
// See README.md in application-factory-template to learn how to delete an application
module "project-service-cloudresourcemanager" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "4.0.0"

  project_id = var.project_id

  activate_apis = [
    "artifactregistry.googleapis.com",
    //"clouddeploy.googleapis.com",
    "container.googleapis.com"
  ]
}

// Create GitHub webhook to invoke Cloud Build trigger
module "app-web-hook" {
  count  = var.trigger_type == "webhook" ? 1 : 0
  source = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules//webhooks/application"
  
  app_name        = var.application_name
  project_number  = local.project_number
  app_repo_name   = var.application_name
  project_id      = var.project_id
  service_account = var.cloudbuild_service_account
  secret_project_id = var.secret_project_id
  private_pool    = data.google_secret_manager_secret_version.private-pool.secret_data
}

//Create GitHub trigger to invoke Cloud Build trigger
module "app-github-trigger" {
  count  = var.trigger_type == "github" ? 1 : 0
  source = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules//github-triggers/application"

  project_id      = var.project_id
  service_account = var.cloudbuild_service_account
  github_org      = var.org_name_to_clone_template_from
  app_name        = var.application_name
}

module "artifact-registry" {
  source = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules//artifact-registry"

  id          = var.application_name
  project_id  = var.project_id
  location    = var.region
  description = "Artifact registry for ${var.application_name} in ${var.project_id}"

  depends_on = [
    module.project-service-cloudresourcemanager
  ]
}

module "cloud-deploy-targets" {
  source = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules//cloud-deploy-targets"

  service_account = var.clouddeploy_service_account
  project         = var.project_id
  location        = var.region
  depends_on = [
    module.project-service-cloudresourcemanager
  ]
}

resource "google_clouddeploy_delivery_pipeline" "primary" {
  location     = var.region
  name         = var.application_name
  description  = "Deployment pipeline for ${var.application_name}"

  project      = var.project_id

  serial_pipeline {
    stages {
      profiles  = ["dev"]
      target_id = module.cloud-deploy-targets.dev-target.target.name
    }

    stages {
      profiles  = ["staging"]
      target_id = module.cloud-deploy-targets.staging-target.target.name
    }

    stages {
      profiles  = ["prod-1"]
      target_id = module.cloud-deploy-targets.prod-1-target.target.name
    }

    stages {
      profiles  = ["prod-2"]
      target_id = module.cloud-deploy-targets.prod-2-target.target.name
    }

  }
}