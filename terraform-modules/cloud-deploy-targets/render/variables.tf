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

variable "cluster_name" {
  type        = string
  description = "GKE cluster name."
}

variable "cluster_path" {
  type        = string
  description = "GKE cluster path."
}

variable "require_approval" {
  type        = bool
  default     = false
  description = "Approval flag that permits deployment in the target."
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