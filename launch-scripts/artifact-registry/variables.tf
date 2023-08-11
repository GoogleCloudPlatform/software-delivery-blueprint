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
  description = "Id of the project where the artifact registry is being created."
  type        = string
}

variable "id" {
  description = "Id of the Artifact registry."
  type        = string
}

variable "location" {
  description = "Region of the Artifact registry."
  type        = string
}

variable "format" {
  description = "Format of the Artifact registry."
  default     = "DOCKER"
  type        = string
}

variable "description" {
  description = "Description of the Artifact registry."
  type        = string
}