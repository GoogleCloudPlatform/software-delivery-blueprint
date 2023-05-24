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
  type        = string
  description = "Name of the application which will also be the name of the repo."
}

variable "org_name_to_clone_template_from" {
  type        = string
  description = "GitHub org where the repo will be created."
}

variable "trigger_type" {
  type        = string
  default     = "webhook"
  description = "webhook to github trigger."
}

variable "project_number" {
  type        = number
  description = "Project number of the application admin/seed project."
}

variable "project_id" {
  type        = string
  description = "Id of the application admin/seed project."
}

variable "service_account" {
  type        = string
  description = "CICD Cloud Build IaC."
}

variable "app_runtime" {
  type        = string
  description = "Type of runtime for the application e.g java or golang or python etc."
}

variable "github_user" {
  type        = string
  description = "GitHub username."
}

variable "github_email" {
  type        = string
  description = "GitHub user email."
}

variable "org_id" {
  type        = string
  description = "GCP org id."
}

variable "billing_account" {
  type        = string
  description = "GCP billing account."
}

variable "state_bucket" {
  type        = string
  description = "Terraform state bucket for the IaC."
}

variable "ci_sa" {
  type        = string
  description = "Cloud Build CICD SA."
}

variable "cd_sa" {
  type        = string
  description = "Cloud Deploy CICD SA."
}

variable "folder_id" {
  type        = string
  default     = ""
  description = "GCP folder ID under which you are creating the application."
}

variable "region" {
  type        = string
  description = "Region where the application related resources will be created."
}

variable "secret_project_id" {
  type = string
  description = "ID of the project that holds common secrets."
}