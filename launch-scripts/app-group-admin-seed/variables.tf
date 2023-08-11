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

variable "project_name" {
  type        = string
  description = "Name of the application admin project that should be created, this will be same as the application name."
}

variable "org_id" {
  type        = string
  description = "Google Cloud organization identifier."
}

variable "folder_id" {
  type        = string
  default     = ""
  description = "Google Cloud folder identifier that the application admin project will be created in."
}

variable "billing_account" {
  type        = string
  description = "Billing account identifier that will be linked to the application admin project."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "The region that the IaC bucket should reside in."
}

variable "sec_region" {
  type        = string
  description = "Secondary region for app deployment."
}

variable "create_service_account" {
  type        = bool
  default     = true
  description = "If set to true, Terraform will create the service accounts for Cloud Build IaC and CICD and Cloud Deploy and grant required permissions to them."
}

variable "app_name" {
  type        = string
  description = "Name of the application being created."
}

variable "env" {
  type        = list
  description = "environment list for the application."
}

variable "app_factory_project" {
  type = string
  description = "project id of the application factory"
}