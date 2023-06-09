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

output "iac_bucket_name" {
  value       = google_storage_bucket.iac-state-bucket.name
  description = "Name of the bucket that stores the IaC state files."
}

output "workload_gsa" {
  value       = google_service_account.workload-identity-sa
  description = "The map containing env and the service account created for workload identity."
}

output "iac_sa_id" {
  value       = google_service_account.iac-sa.id
  description = "The identifier for the service account created to run the IaC pipeline."
}

output "iac_sa_email" {
  value       = google_service_account.iac-sa.email
  description = "The email for the service account created to run the IaC pipeline."
}

output "cicd_sa_id" {
  value       = google_service_account.cicd-sa.id
  description = "The identifier for the service account created to run the CI/CD pipeline."
}

output "cicd_sa_email" {
  value       = google_service_account.cicd-sa.email
  description = "The email for the service account created to run the CI/CD pipeline."
}