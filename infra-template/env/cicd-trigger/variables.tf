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

variable "application_name" {
  type = string
  description = "Name of the application which will also be the name of the repo"
  default = "YOUR_APPLICATION"
}

variable "org_name_to_clone_template_from" {
  type = string
  description = "github org where the repo will be created"
  default = "YOUR_GITHUB_ORG"
}

variable "trigger_type" {
  type = string
  default = "YOUR_TRIGGER_TYPE"
  description = "webhook or github trigger"
}

variable "project_id" {
  type = string
  description = "project id of the application admin/seed project"
  default = "YOUR_APP_ADMIN_PROJECT"
}

variable "cloudbuild_service_account" {
  type = string
  description = "Cloud Build SA for application builds"
  default = "YOUR_CI_SA"
}

variable "clouddeploy_service_account" {
  type = string
  description = "Cloud Deploy SA for releases to k8s"
  default = "YOUR_CD_SA"
}

variable "region" {
  type = string
  description = "Region where resources like Cloud Deploy and Artifact Registry should be created."
  default = "YOUR_REGION"
}
