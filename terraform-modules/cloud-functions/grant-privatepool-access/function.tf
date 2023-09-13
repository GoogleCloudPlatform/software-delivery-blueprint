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

# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "source" {
  type        = "zip"
  source_dir  = "${path.module}/../src/provide-privatepool-permissions"
  output_path = "/tmp/function.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "zip" {
  source       = data.archive_file.source.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the file's content
  # to force the zip to be updated as soon as a change occurs
  name         = "src-${data.archive_file.source.output_md5}.zip"
  bucket       = google_storage_bucket.function_bucket.name

  depends_on   = [
    google_storage_bucket.function_bucket,
    data.archive_file.source
  ]
}

# Create the Cloud function triggered by a `Finalize` event on the trigger bucket
resource "google_cloudfunctions_function" "function" {
  project               = var.project_id
  name                  = var.function_name
  runtime               = "python37"
  region                = var.region
  # Get the source code of the cloud function as a Zip compression
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.zip.name
  service_account_email = google_service_account.function-sa.email
  # Must match the function name in the cloud function `main.py` source code
  entry_point           = "update_permissions"
  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = google_storage_bucket.trigger_bucket.name
  }
  ingress_settings = "ALLOW_INTERNAL_ONLY"
  # Dependencies are automatically inferred so these lines can be deleted
  depends_on            = [
    google_storage_bucket.function_bucket,  # declared in `gcs.tf`
    google_storage_bucket_object.zip
  ]
}
