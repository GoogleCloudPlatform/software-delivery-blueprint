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

# Create custom SA for cloud function
resource "google_service_account" "function-sa" {
  project      = var.project_id
  account_id   = "secrets-function-sa"
  display_name = "Cloud Function service account"
}

resource "google_project_iam_member" "function-sa-roles" {
  project = var.project_id
  for_each = toset([
    "roles/resourcemanager.projectIamAdmin",
    "roles/storage.objectViewer"
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.function-sa.email}"
}