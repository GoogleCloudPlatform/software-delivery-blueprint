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
  source                  = "terraform-google-modules/project-factory/google"
  version                 = "11.3.0"
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
    "apikeys.googleapis.com"
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

// Grant org level roles to the Cloud Build SA for IaC pipeline. TODO: We can refine the role to be on the specific billing account rather than on the org
resource "google_organization_iam_member" "iac-sa-billing-user" {
  count  = var.create_service_account ? 1 : 0
  org_id = var.org_id
  role   = "roles/billing.user"
  member = "serviceAccount:${google_service_account.iac-sa[0].email}"
}

resource "google_organization_iam_member" "iac-sa-project-creator" {
  count  = var.create_service_account ? 1 : 0
  org_id = var.org_id
  role   = "roles/resourcemanager.projectCreator"
  member = "serviceAccount:${google_service_account.iac-sa[0].email}"
}

// State storage bucket and IAM for the IaC pipeline
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
    "roles/storage.objectViewer"
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

// Add Cloud Build CICD SA to IAM group through custom SA impersonation
// The provider to do the impersonation is passed from the parent module
resource "google_cloud_identity_group_membership" "iam_group_managers" {
  provider = google.impersonated
  group    = format("%s/%s", "groups", var.group_id)
  preferred_member_key { id = google_service_account.cloud-deploy[0].email }
  # MEMBER role must be specified. The order of roles should not be changed.
  roles { name = "MEMBER" }
  roles { name = "MANAGER" }
}
//Allow Cloud Build IaC to impersonate cloud deploy SA to do the deployment
//TODO : not needed
resource "google_service_account_iam_member" "iac-sa-impersonate-cd" {
  service_account_id = google_service_account.cloud-deploy[0].name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.iac-sa[0].email}"
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

// Create new service accounts per environment for workload identity
locals {
  wi_roles = ["roles/secretmanager.secretAccessor", "roles/secretmanager.admin", "roles/storage.objectCreator", "roles/storage.objectViewer", "roles/storage.admin"]
  wi_roles_perm_combo = [
    for pair in setproduct(local.wi_roles, var.env) : {
      role        = pair[0]
      member      = "serviceAccount:${google_service_account.workload-identity-sa[pair[1]].email}"
      environment = pair[1]
    }
  ]
  wi_roles_mapping = {
    for m in local.wi_roles_perm_combo : "${m.role} ${m.environment}" => m
  }
}
// Create a new service account for workload identity
resource "google_service_account" "workload-identity-sa" {
  for_each     = toset(var.env)
  project      = module.admin-project.project_id
  account_id   = "${each.key}-wi-${var.app_name}"
  display_name = "Workload Identity SA for ${each.key} environment"
}

// Grant project level roles to the workload identity SA
resource "google_project_iam_member" "workload-identity-sa-roles" {
  project  = module.admin-project.project_id
  for_each = local.wi_roles_mapping
  role     = each.value.role
  member   = each.value.member
}