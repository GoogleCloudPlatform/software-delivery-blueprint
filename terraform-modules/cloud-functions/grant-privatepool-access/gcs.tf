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

# Create GCS for storing function code
resource "google_storage_bucket" "function_bucket" {
  name     = "${var.project_id}-${var.function_gcs}"
  location = var.region
  project  = var.project_id
}

# Create GCS for triggering the function on addition of an object
resource "google_storage_bucket" "trigger_bucket" {
  name = "${var.project_id}-${var.trigger_gcs}"
  location = var.region
  project  = var.project_id
}

# Permission the trigger_gcs bucket to let CloudBuild SA in Application Factory to upload object to it.
resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.trigger_bucket.name
  role = "roles/storage.admin"
  member = "serviceAccount:${var.app_factory_project}@cloudbuild.gserviceaccount.com"
  depends_on = [ google_storage_bucket.trigger_bucket ]
}

# Add the trigger_gcs in secretmanager in common secret management project
resource "google_secret_manager_secret" "trigger-bucket" {
  secret_id = "privatepool-permission-fn-trg-bucket-${var.env}"
  replication {
    automatic = true
  }
  project = var.secrets_project_id
}
resource "google_secret_manager_secret_version" "trigger-bucket-secret" {
  secret      = google_secret_manager_secret.trigger-bucket.id
  secret_data = google_storage_bucket.trigger_bucket.name
  depends_on = [ google_storage_bucket.trigger_bucket ]
}

resource "google_secret_manager_secret_iam_member" "trigger-bucket-secret-access" {
  secret_id = google_secret_manager_secret.trigger-bucket.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.app_factory_project}@cloudbuild.gserviceaccount.com"
}