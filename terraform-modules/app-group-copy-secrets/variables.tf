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

variable "secrets" {
  type        = list(string)
  description = "The list of all the secrets required to be copied from application factory to application admin project."
}

variable "infra_project_id" {
  description = "Id of the multi-tenant infrastructure project."
  type        = string
}

variable "seed_project_id" {
  description = "Id of the application admin project."
  type        = string
}

variable "cb_iac_service_account" {
  description = "Cloud Build SA for IaC pipeline."
  type        = string
}

variable "app_name" {
  description = "Application name."
  type        = string
}

variable "region" {
  description = "Google Cloud region."
  type        = string
}