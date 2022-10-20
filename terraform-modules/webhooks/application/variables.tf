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

variable "app_name" {
  description = "Name of the application for which the trigger is being created"
  type        = string
}

variable "project_number" {
  description = "Project number of the application admin project."
  type        = number
}

variable "app_repo_name" {
  description = "Name of the app repo."
  type        = string
}

variable "project_id" {
  description = "Id of the application admin project."
  type        = string
}

variable "service_account" {
  description = "Service Account to associate Cloud Build trigger with."
  type        = string
}
