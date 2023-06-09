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

// Create a new service account for Cloud Build to be used for the IaC pipelines for the application
resource "google_service_account" "iac-sa" {
  project      = var.project_id
  account_id   = "cloudbuild-app-iac-${var.app_name}"
  display_name = "Cloud Build - Infra as Code service account for application ${var.app_name}"
}

// Grant project level roles to the Cloud Build SA for IaC pipeline
resource "google_project_iam_member" "iac-sa-cloudbuild-roles" {
  project = var.project_id
  for_each = toset([
    "roles/cloudbuild.builds.builder",
    "roles/logging.logWriter",
    "roles/owner"
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.iac-sa.email}"
}
// Create a new service account for Cloud Build to be used for the application CI/CD pipeline
resource "google_service_account" "cicd-sa" {
  project      = var.project_id
  account_id   = "cloudbuild-app-cicd-${var.app_name}"
  display_name = "Cloud Build - CI/CD service account for application ${var.app_name}"
}

resource "google_project_iam_member" "cicd-sa-cloudbuild-roles" {
  project = var.project_id
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
  member = "serviceAccount:${google_service_account.cicd-sa.email}"
}

//Allow Cloud Build IaC SA to impersonate Cloud Build CICD SA so the former can create a cloud build trigger and attach the latter to it,
resource "google_service_account_iam_member" "iac-sa-impersonate-cicd" {
  service_account_id = google_service_account.cicd-sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.iac-sa.email}"
}

//Allow Cloud Build CICD to impersonate cloud deploy SA to do the deployment
data "google_secret_manager_secret_version" "cloud-deploy" {
  project = var.project_id
  secret = "clouddeploy-sa-id"
}

resource "google_service_account_iam_member" "cicd-sa-impersonate-cd" {
  service_account_id = data.google_secret_manager_secret_version.cloud-deploy.secret_data
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.cicd-sa.email}"
}

// State storage bucket and IAM for the IaC pipeline
resource "google_storage_bucket" "iac-state-bucket" {
  name                        = join("-", [var.project_id,var.app_name, "infra-tf"])
  project                     = var.project_id
  location                    = var.region
  storage_class               = null
  uniform_bucket_level_access = true
  labels                      = null
  force_destroy               = true
}

resource "google_storage_bucket_iam_member" "bucket-members" {
  bucket = google_storage_bucket.iac-state-bucket.name
  for_each = toset([
    "roles/storage.objectCreator",
    "roles/storage.objectViewer",
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.iac-sa.email}"
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
  project      = var.project_id
  account_id   = "${each.key}-wi-${var.app_name}"
  display_name = "Workload Identity SA for ${each.key} environment"
}

// Grant project level roles to the workload identity SA
resource "google_project_iam_member" "workload-identity-sa-roles" {
  project  = var.project_id
  for_each = local.wi_roles_mapping
  role     = each.value.role
  member   = each.value.member
}
