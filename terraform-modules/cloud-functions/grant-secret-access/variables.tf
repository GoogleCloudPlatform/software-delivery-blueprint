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

variable "project_id" {
  type = string
  description = "Project Id where the function will be created."
}

variable "function_name" {
  type = string
  description = "Name of the cloud function."
}

variable "function_gcs" {
  type = string
  description = "GCS bucket to store function code."
}

variable "trigger_gcs" {
  type = string
  description = "GCS bucket to trigger function on addition of an object."
}

variable "region" {
  type = string
  description = "GCP region."
}

variable "app_factory_project" {
  type = number
  description = "Project Number of Application Factory."
}