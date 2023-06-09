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
  type = string
  description = "ID of the current project."
}
variable "env" {
  default = "dev"
  description = "Environment"
}

variable "acm_repo" {
  default = "YOUR_ACM_REPO"
  description = "Repo that will be used for ACM"
}
variable "github_user" {
  type = string
  description = "username for github"
}
variable "github_email" {
  type = string
  description = "email for github user"
}
variable "github_org" {
  type = string
  description = "github organization"
}
variable "github_token" {
  type = string
  description = "The access token that should be used for authenticating to GitHub."
  sensitive = true
}

variable "network_name" {
  default = "gke-vpc-network-dev"
  description = "VPC network where GKE cluster will be created"
}
variable "routing_mode" {
  default = "GLOBAL"
}
variable "subnet_01_name" {
  default = "gke-vpc-network-dev-subnet-01"
}
variable "subnet_01_ip" {
  default = "10.40.0.0/22"
}
variable "subnet_01_region" {
  default = "YOUR_REGION"
}
variable "subnet_01_description" {
  default = "subnet 01 in"
}
variable "subnet_02_name" {
  default = "gke-vpc-network-dev-subnet-02"
}
variable "subnet_02_ip" {
  default = "10.12.0.0/22"
}
variable "subnet_02_region" {
  default = "YOUR_SECONDARY_REGION"
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
