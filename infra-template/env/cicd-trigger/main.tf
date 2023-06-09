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

locals{
  project_number = data.google_project.project_number.number
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
  region          = var.region
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

}

data "google_secret_manager_secret_version" "dev-target" {
  secret = "dev"
  project = var.project_id
}
data "google_secret_manager_secret_version" "staging-target" {
  secret = "staging"
  project = var.project_id
}
data "google_secret_manager_secret_version" "prod1-target" {
  secret = "prod1"
  project = var.project_id
}
data "google_secret_manager_secret_version" "prod2-target" {
  secret = "prod2"
  project = var.project_id
}

resource "google_clouddeploy_delivery_pipeline" "primary" {
  location     = var.region
  name         = var.application_name
  description  = "Deployment pipeline for ${var.application_name}"

  project      = var.project_id

  serial_pipeline {
    stages {
      profiles  = ["dev"]
      target_id = data.google_secret_manager_secret_version.dev-target.secret_data
    }

    stages {
      profiles  = ["staging"]
      target_id = data.google_secret_manager_secret_version.staging-target.secret_data
    }

    stages {
      profiles  = ["prod-1"]
      target_id = data.google_secret_manager_secret_version.prod1-target.secret_data
    }

    stages {
      profiles  = ["prod-2"]
      target_id = data.google_secret_manager_secret_version.prod2-target.secret_data
    }

  }
}