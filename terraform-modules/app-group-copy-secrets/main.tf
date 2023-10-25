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

locals {
  env_repo = "${var.app_name}-env"
}

//Following section copies the secrets from multi-tenant infra/platform project to the application seed/admin project
data "google_secret_manager_secret_version" "read-secret" {
  for_each = toset(var.secrets)
  secret   = each.key
  project  = var.infra_project_id
}

resource "google_secret_manager_secret" "create-secret" {
  for_each  = toset(var.secrets)
  secret_id = split("/", data.google_secret_manager_secret_version.read-secret[each.key].name)[3]
  replication {
    auto {}
  }
  project = var.seed_project_id
}

resource "google_secret_manager_secret_version" "secret-value" {
  for_each    = toset(var.secrets)
  secret      = google_secret_manager_secret.create-secret[each.key].id
  secret_data = data.google_secret_manager_secret_version.read-secret[each.key].secret_data
}

resource "google_secret_manager_secret_iam_member" "secret-permission" {
  for_each  = toset(var.secrets)
  secret_id = google_secret_manager_secret.create-secret[each.key].id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.cb_iac_service_account}"
}

//Following section creates new secrets in application seed/admin project
resource "google_secret_manager_secret" "app-name" {
  secret_id = "app-name"
  replication {
    auto {}
  }
  project = var.seed_project_id
}
resource "google_secret_manager_secret_version" "app-name-secret" {
  secret      = google_secret_manager_secret.app-name.id
  secret_data = var.app_name
}

resource "google_secret_manager_secret_iam_member" "app-name-secret-access" {
  secret_id = google_secret_manager_secret.app-name.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.cb_iac_service_account}"
}

resource "google_secret_manager_secret" "env-repo" {
  secret_id = "env-repo"
  replication {
    auto {}
  }
  project = var.seed_project_id
}
resource "google_secret_manager_secret_version" "env-repo-secret" {
  secret      = google_secret_manager_secret.env-repo.id
  secret_data = local.env_repo
}

resource "google_secret_manager_secret_iam_member" "env-repo-secret-access" {
  secret_id = google_secret_manager_secret.env-repo.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.cb_iac_service_account}"
}

resource "google_secret_manager_secret" "region" {
  secret_id = "region"
  replication {
    auto {}
  }
  project = var.seed_project_id
}
resource "google_secret_manager_secret_version" "region-secret" {
  secret      = google_secret_manager_secret.region.id
  secret_data = var.region
}

resource "google_secret_manager_secret_iam_member" "region-secret-access" {
  secret_id = google_secret_manager_secret.region.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.cb_iac_service_account}"
}