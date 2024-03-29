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

variable "project_id" {
  description = "ID of your platform setup project/platform seed project"
}
variable "app_factory_project_id" {
  type = string
}
variable "app_factory_project_num" {
  type = number
  description = "project number of application factory"
}
variable "secrets_project_id" {
  type = string
  description = "Project ID of the projects hosting all secrets"
}

variable "billing_account" {
  description = "GCP billing account"
}
variable "org_id" {
  description = "GCP org id"
}
variable "github_user" {
  type = string
}
variable "github_email" {
  type = string
}
variable "github_org" {
  type = string
}
variable "github_token" {
  description = "The access token that should be used for authenticating to GitHub."
  sensitive = true
}
variable "folder_id" {
}
variable "acm_repo" {
  type = string
}
variable "env" {
  default = "prod"
}
variable "base_project_name" {
  default = "sdp-gke"
  description = "Name of the project that will host GKE cluster"
}
variable "network_name" {
  default = "gke-vpc-network-prod"
  description = "VPC network where GKE cluster will be created"
}
variable "routing_mode" {
  default = "GLOBAL"
}
variable "subnet_01_name" {
  default = "gke-vpc-network-prod-subnet-01"
}
variable "subnet_01_ip" {
  default = "10.40.0.0/22"
}
variable "subnet_01_region" {
  description = "primary region where resources will be created"
}
variable "subnet_01_description" {
  default = "subnet 01"
}
variable "subnet_02_name" {
  default = "gke-vpc-network-prod-subnet-02"
}
variable "subnet_02_ip" {
  default = "10.12.0.0/22"
}
variable "subnet_02_region" {
  description = "secondary region where resources will be created"
}
variable "subnet_02_description" {
  default = "subnet 02"
}
variable "subnet_01_secondary_svc_1_name" {
  default = "subnet-01-service-01-name"
}
variable "subnet_01_secondary_svc_1_range" {
  default = "10.5.0.0/20"
}
variable "subnet_01_secondary_svc_2_name" {
  default = "subnet-01-service-02-name"
}
variable "subnet_01_secondary_svc_2_range" {
  default = "10.5.16.0/20"
}
variable "subnet_01_secondary_pod_name" {
  default = "subnet-01-secondary-pod-name"
}
variable "subnet_01_secondary_pod_range" {
  default = "10.0.0.0/14"
}
variable "subnet_02_secondary_svc_1_name" {
  default = "subnet-02-service-01-name"
}
variable "subnet_02_secondary_svc_1_range" {
  default = "10.13.0.0/20"
}
variable "subnet_02_secondary_svc_2_name" {
  default = "subnet-02-service-02-name"
}
variable "subnet_02_secondary_svc_2_range" {
  default = "10.13.16.0/20"
}
variable "subnet_02_secondary_pod_name" {
  default = "subnet-02-secondary-pod-name"
}
variable "subnet_02_secondary_pod_range" {
  default = "10.8.0.0/14"
}
