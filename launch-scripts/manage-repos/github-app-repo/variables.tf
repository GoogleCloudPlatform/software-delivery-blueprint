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
  description = "webhook or github trigger."
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
  description = "CICD Cloud Build SA."
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

variable "namespace" {
  type        = map
  description = "K8s namespace to be added in the kubernetes files in app repo."
}

//variable "ksa" {
//  type        = map
//  description = "K8s service account to be added in the kubernetes files in app repo."
//}

variable "env" {
  type        = list
  description = "List of environments for which the landing zone is to be created."
}

variable "region" {
  type        = string
  description = "Google Cloud region."
}

variable "secret_project_id" {
  type = string
  description = "ID of the project that holds common secrets."
}

variable "app_suffix" {
  type = string
  description = "Suffix that will be applied to the application projects that will be created as IaC trigger of the application."
}