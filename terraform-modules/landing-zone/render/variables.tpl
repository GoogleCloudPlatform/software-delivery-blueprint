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

variable "gsa" {
  description = "Google service account"
  type = string
}

variable "app_name" {
  description = "Name of the application"
  type = string
}

variable "ksa" {
  description = "Kubernetes service account"
  type = string
}

variable "project_id" {
  description = "Application admin project id"
  type = string
}

variable "cicd_sa" {
  description = "CICD service account for the application"
  type = string
}

variable "env" {
  description = "Environment"
  type = string
}

variable "namespace" {
  description = "K8s namespace for the app"
  type = string
}

variable "git_user" {
  description = "git user"
  type = string
}

variable "git_email" {
  description = "git email"
  type = string
}

variable "git_org" {
  description = "git organization"
  type = string
}

variable "git_token" {
  description = "git token"
  type = string
}

variable "acm_repo" {
  description = "ACM repository"
  type = string
}