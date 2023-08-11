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

// Create admin project
module "admin-project" {
  source                  = "../project-factory"
  random_project_id       = true
  billing_account         = var.billing_account
  name                    = var.project_name
  org_id                  = var.org_id
  folder_id               = var.folder_id
  default_service_account = "keep"
  activate_apis = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudfunctions.googleapis.com",
    "apikeys.googleapis.com",
    "run.googleapis.com"
  ]
}

// Create a new service account for Cloud Build to be used for the IaC pipeline
resource "google_service_account" "iac-sa" {
  count        = var.create_service_account ? 1 : 0
  project      = module.admin-project.project_id
  account_id   = "cloudbuild-iac"
  display_name = "Cloud Build - Infra as Code service account"
}

// Grant project level roles to the Cloud Build SA for IaC pipeline
resource "google_project_iam_member" "iac-sa-cloudbuild-roles" {
  project = module.admin-project.project_id
  for_each = toset([
    "roles/cloudbuild.builds.builder",
    "roles/logging.logWriter",
    "roles/owner"
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.iac-sa[0].email}"
}

resource "google_storage_bucket" "iac-state-bucket" {
  name                        = join("-", [module.admin-project.project_id, "infra-tf"])
  project                     = module.admin-project.project_id
  location                    = var.region
  storage_class               = null
  uniform_bucket_level_access = true
  labels                      = null
  force_destroy               = true
}

resource "google_storage_bucket_iam_member" "bucket-members-2" {
  bucket = google_storage_bucket.iac-state-bucket.name
  for_each = toset([
    "roles/storage.objectCreator",
    "roles/storage.objectViewer",
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.iac-sa[0].email}"
}

//Grant IaC SA to read secrets in application factory
resource "google_project_iam_member" "iac-sa-roles" {
  project = var.app_factory_project
  for_each = toset([
    "roles/secretmanager.secretAccessor",
    "roles/secretmanager.viewer"
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.iac-sa[0].email}"
}

// Create a new service account for Cloud Build to be used for the application CI/CD pipeline
resource "google_service_account" "cicd-sa" {
  count        = var.create_service_account ? 1 : 0
  project      = module.admin-project.project_id
  account_id   = "cloudbuild-cicd"
  display_name = "Cloud Build - CI/CD service account"
}

resource "google_project_iam_member" "cicd-sa-cloudbuild" {
  project = module.admin-project.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_service_account.cicd-sa[0].email}"
}

resource "google_project_iam_member" "cicd-sa-cloudbuild-roles" {
  project = module.admin-project.project_id
  for_each = toset([
    "roles/serviceusage.serviceUsageAdmin",
    "roles/clouddeploy.operator",
    "roles/cloudbuild.builds.builder",
    "roles/secretmanager.secretAccessor",
    "roles/secretmanager.admin",
    "roles/serviceusage.apiKeysAdmin",
    "roles/storage.admin",
    "roles/artifactregistry.writer"
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.cicd-sa[0].email}"
}

//Create SA for cloud deploy
resource "google_service_account" "cloud-deploy" {
  count        = var.create_service_account ? 1 : 0
  project      = module.admin-project.project_id
  account_id   = "clouddeploy"
  display_name = "Cloud Deploy service account"
}

//Permission cloud deploy SA
resource "google_project_iam_member" "cloud-deploy-roles" {
  project = module.admin-project.project_id
  for_each = toset([
    "roles/logging.logWriter",
    "roles/clouddeploy.jobRunner",
    "roles/storage.objectViewer",
    "roles/run.developer",
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.cloud-deploy[0].email}"
}

//Add the cloud deploy account to secretmanager so the cicd pipelines can pull and use it.
//Also provide access to Cloud Build cicd service account to look up that secret.
resource "google_secret_manager_secret" "clouddeploy-sa" {
  secret_id = "clouddeploy-sa"
  replication {
    automatic = true
  }
  project = module.admin-project.project_id
}

resource "google_secret_manager_secret_version" "clouddeploy-sa-secret" {
  provider    = google
  secret      = google_secret_manager_secret.clouddeploy-sa.id
  secret_data = "${google_service_account.cloud-deploy[0].email}"
}

resource "google_secret_manager_secret_iam_member" "clouddeploy-sa-secret-access" {
  provider  = google
  secret_id = google_secret_manager_secret.clouddeploy-sa.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.iac-sa[0].email}"
}

//Allow Cloud Build IaC SA to impersonate Cloud Build CICD SA so the former can create a cloud build trigger and attach the latter to it,
resource "google_service_account_iam_member" "iac-sa-impersonate-cicd" {
  service_account_id = google_service_account.cicd-sa[0].name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.iac-sa[0].email}"
}

//Allow Cloud Build CICD to impersonate cloud deploy SA to do the deployment
resource "google_service_account_iam_member" "cicd-sa-impersonate-cd" {
  service_account_id = google_service_account.cloud-deploy[0].name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.cicd-sa[0].email}"
}
/*
// Create new service accounts per environment for service identity
locals {
  si_roles = ["roles/secretmanager.secretAccessor", "roles/secretmanager.admin", "roles/storage.objectCreator", "roles/storage.objectViewer", "roles/storage.admin"]
  si_roles_perm_combo = [
    for pair in setproduct(local.si_roles, var.env) : {
      role        = pair[0]
      member      = "serviceAccount:${google_service_account.service-identity-sa[pair[1]].email}"
      environment = pair[1]
    }
  ]
  si_roles_mapping = {
    for m in local.si_roles_perm_combo : "${m.role} ${m.environment}" => m
  }
}
// Create a new service account for service identity
resource "google_service_account" "service-identity-sa" {
  for_each     = toset(var.env)
  project      = module.admin-project.project_id
  account_id   = "${each.key}-si-${var.app_name}"
  display_name = "Service Identity SA for ${each.key} environment"
}

// Grant project level roles to the service identity SA
resource "google_project_iam_member" "service-identity-sa-roles" {
  project  = module.admin-project.project_id
  for_each = local.si_roles_mapping
  role     = each.value.role
  member   = each.value.member
}
// Allow CloudDeploy SA to impersonate the service identity accounts so it can deploy cloudrun services with the,
resource "google_service_account_iam_member" "cd-impersonate-si" {
  for_each           = toset(var.env)
  service_account_id = google_service_account.service-identity-sa[each.key].name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.cloud-deploy[0].email}"
}
*/

// Generate a 4 digit random number that will be suffixed to application projects

resource "random_id" "app-project-suffix" {
  keepers = {
    project_id = module.admin-project.project_id
  }
  byte_length = 2
}

//Following section creates new secrets in application admin project
resource "google_secret_manager_secret" "app-suffix" {
  secret_id = "app-suffix"
  replication {
    automatic = true
  }
  project = module.admin-project.project_id
}
resource "google_secret_manager_secret_version" "app-suffix-secret" {
  secret      = google_secret_manager_secret.app-suffix.id
  secret_data = random_id.app-project-suffix.hex
}

resource "google_secret_manager_secret_iam_member" "app-sfx-secret-access-1" {
  secret_id = google_secret_manager_secret.app-suffix.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.iac-sa[0].email}"
}

resource "google_secret_manager_secret" "app-name" {
  secret_id = "app-name"
  replication {
    automatic = true
  }
  project = module.admin-project.project_id
}
resource "google_secret_manager_secret_version" "app-name-secret" {
  secret      = google_secret_manager_secret.app-name.id
  secret_data = var.app_name
}

resource "google_secret_manager_secret_iam_member" "app-name-secret-access" {
  secret_id = google_secret_manager_secret.app-name.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cicd-sa[0].email}"
}

resource "google_secret_manager_secret" "region" {
  secret_id = "region"
  replication {
    automatic = true
  }
  project = module.admin-project.project_id
}
resource "google_secret_manager_secret_version" "region-secret" {
  secret      = google_secret_manager_secret.region.id
  secret_data = var.region
}

resource "google_secret_manager_secret_iam_member" "region-secret-access" {
  secret_id = google_secret_manager_secret.region.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cicd-sa[0].email}"
}

resource "google_secret_manager_secret" "sec_region" {
  secret_id = "sec_region"
  replication {
    automatic = true
  }
  project = module.admin-project.project_id
}
resource "google_secret_manager_secret_version" "sec_region-secret" {
  secret      = google_secret_manager_secret.sec_region.id
  secret_data = var.sec_region
}

resource "google_secret_manager_secret_iam_member" "sec_region-secret-access" {
  secret_id = google_secret_manager_secret.sec_region.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cicd-sa[0].email}"
}