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

variable "subnet" {
  type = object({
    description              = string
    gateway_address          = string
    id                       = string
    ip_cidr_range            = string
    name                     = string
    network                  = string
    private_ip_google_access = string
    project                  = string
    region                   = string
    secondary_ip_range = list(object({
      ip_cidr_range = string
      range_name    = string
    }))
    self_link = string
  })
  description = "Subnet details for the GKE cluster coming from project module."
}

variable "suffix" {
  type        = number
  description = "Arbitrary number to chose subnet1 or subnet2 for the GKE cluster"
}

variable "env" {
  type        = string
  description = "Environment."
}

variable "project_id" {
  type        = string
  description = "Id of the project where GKE cluster is to be created."
}

variable "zone" {
  type        = list
  description = "List zones to create GKE cluster in."
}

variable "project_number" {
  type        = string
  description = "Project number where GKE cluster is to be created."
}

variable "security_group_domain" {
  type        = string
  description = "Authenticator security group domain used in RBAC for the GKE cluster."
  default     = ""
}
