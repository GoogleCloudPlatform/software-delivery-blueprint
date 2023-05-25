# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable "secrets_project_id" {
  description = "Id of the project hosting all secrets"
}
variable "infra_project_id" {
  description = "Id of the platform admin project"
}
variable "function_name" {
  default = "add-secret-permission"
  description = "Name of the Cloud Function that will grant secret read permissions"
}
variable "function_gcs" {
  default = "add-secret-permission-src"
  description = "Name of the GSC bucket hosting code for the Cloud Function"
}

variable "trigger_gcs" {
  default = "add-secret-permission-trg"
  description = "Name of the GSC bucket that will trigger the Cloud Function"
}
variable "app_factory_project_id" {
  description = "ID of the Application Factory project"
}
variable "region" {
  default = "YOUR_REGION"
  description = "Region for creating the Cloud Function and GCS buckets"
}

variable "app_factory_project_num" {
  type = number
  description = "project number of application factory"
}