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

variable "service_account_name" {
  type        = string
  description = "GKE Service account that will be given permissions to access the Artifact Registry repo."
}

variable "cluster_name" {
  type        = string
  description = "GKE cluster name."
}

variable "git_user" {
  type        = string
  description = "GitHub user."
}

variable "git_email" {
  type        = string
  description = "GitHub user email."
}

variable "git_org" {
  type        = string
  description = "GitHub org."
}

variable "github_token" {
  type        = string
  sensitive   = true
  description = "GitHub access token."
}

variable "git_repo" {
  type        = string
  description = "GitHub repo name."
}