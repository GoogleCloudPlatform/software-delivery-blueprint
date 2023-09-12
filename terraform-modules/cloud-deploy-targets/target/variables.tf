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

variable "location" {
  type        = string
  description = "GCP region."
}

variable "name" {
  type        = string
  description = "Name of the Cloud Deploy target."
}

variable "membership" {
  type        = string
  description = "Hub membership name."
}

variable "require_approval" {
  type        = bool
  default     = false
  description = "Approval flag that permits deployment in the Cloud deploy target."
}

variable "project" {
  type        = string
  description = "Id of the project where the Cloud Deploy target is to be created."
}

variable "service_account" {
  type        = string
  description = "Service Account that will be used to deploy to the Cloud Deploy target."
}

variable "private_pool" {
  type        = string
  description = "Id of the private pool."
}