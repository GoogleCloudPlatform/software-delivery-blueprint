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
  description = "Id of the GCP project where VPC is to be created."
  type = string
}
variable "network_name" {
  description = "Name of the VPC network."
  type = string
}
variable "routing_mode" {
  description = "The network routing mode."
  type = string
}
variable "subnet_01_name" {
  description = "Name of first subnet."
  type = string
}
variable "subnet_01_ip" {
  description = "IP range of first subnet."
  type = string
}
variable "subnet_01_region" {
  description = "Region of first subnet."
  type = string
}
variable "subnet_01_description" {
  description = "Subnet description."
  type = string
}
variable "subnet_02_name" {
  description = "Name of the second subnet."
  type = string
}
variable "subnet_02_ip" {
  description = "IP range of second subnet."
  type = string
}
variable "subnet_02_region" {
  description = "Region of second subnet."
  type = string
}
variable "subnet_02_description" {
  description = "Subnet description."
  type = string
}
variable "subnet_01_secondary_svc_1_name" {
  description = "Name of service IP range."
  type = string
}
variable "subnet_01_secondary_svc_1_range" {
  description = "IP range of the service."
  type = string
}
variable "subnet_01_secondary_svc_2_name" {
  description = "Name of service IP range."
  type = string
}
variable "subnet_01_secondary_svc_2_range" {
  description = "IP range of the service."
  type = string
}
variable "subnet_01_secondary_pod_name" {
  description = "Name of pods IP range."
  type = string
}
variable "subnet_01_secondary_pod_range" {
  description = "IP range of the pods."
  type = string
}
variable "subnet_02_secondary_svc_1_name" {
  description = "Name of service IP range."
  type = string
}
variable "subnet_02_secondary_svc_1_range" {
  description = "IP range of the service."
  type = string
}
variable "subnet_02_secondary_svc_2_name" {
  description = "Name of service IP range."
  type = string
}
variable "subnet_02_secondary_svc_2_range" {
  description = "IP range of the service."
  type = string
}
variable "subnet_02_secondary_pod_name" {
  description = "Name of pods IP range."
  type = string
}
variable "subnet_02_secondary_pod_range" {
  description = "IP range of the pods."
  type = string
}
