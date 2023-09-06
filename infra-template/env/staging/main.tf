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

locals {
  description = [for item in module.create-vpc.network.subnets : item.description]
  gateway_address = [for item in module.create-vpc.network.subnets : item.gateway_address]
  id = [for item in module.create-vpc.network.subnets : item.id]
  ip_cidr_range = [for item in module.create-vpc.network.subnets : item.ip_cidr_range]
  name = [for item in module.create-vpc.network.subnets : item.name]
  network = [for item in module.create-vpc.network.subnets : item.network]
  private_ip_google_access = [for item in module.create-vpc.network.subnets : item.private_ip_google_access]
  project = [for item in module.create-vpc.network.subnets : item.project]
  region = [for item in module.create-vpc.network.subnets : item.region]
  secondary_ip_range =  [for item in module.create-vpc.network.subnets : [ for i in item.secondary_ip_range : { ip_cidr_range =  i.ip_cidr_range  , range_name =  i.range_name } ] ]
  self_link = [for item in module.create-vpc.network.subnets : item.self_link]
  subnet1 = {description = local.description[0] , gateway_address = local.gateway_address[0], id = local.id[0] ,ip_cidr_range = local.ip_cidr_range[0], name = local.name[0] , network = local.network[0] , private_ip_google_access = local.private_ip_google_access[0] , project = local.project[0] , region = local.region[0] , self_link = local.self_link[0] , secondary_ip_range = local.secondary_ip_range[0]  }
  subnet2 = {description = local.description[1] , gateway_address = local.gateway_address[1], id = local.id[1] ,ip_cidr_range = local.ip_cidr_range[1], name = local.name[1] , network = local.network[1] , private_ip_google_access = local.private_ip_google_access[1] , project = local.project[1] , region = local.region[1] , self_link = local.self_link[1] , secondary_ip_range = local.secondary_ip_range[1]  }
}

module "create-gcp-project" {
  source = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//project-factory/"
  base_project_name = var.base_project_name
  billing_account = var.billing_account
  org_id = var.org_id
  folder_id = var.folder_id
  env = var.env
  addtl_apis = [
    "compute.googleapis.com"]
}

module "create-vpc" {
  source = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//vpc/"
  project_id   = module.create-gcp-project.project.project_id
  network_name    = var.network_name
  routing_mode    = var.routing_mode
  subnet_01_name      = var.subnet_01_name
  subnet_01_ip        = var.subnet_01_ip
  subnet_01_region    = var.subnet_01_region
  subnet_01_description      = var.subnet_01_description
  subnet_02_name      = var.subnet_02_name
  subnet_02_ip        = var.subnet_02_ip
  subnet_02_region    = var.subnet_02_region
  subnet_02_description      = var.subnet_02_description
  subnet_01_secondary_svc_1_name    = var.subnet_01_secondary_svc_1_name
  subnet_01_secondary_svc_1_range = var.subnet_01_secondary_svc_1_range
  subnet_01_secondary_svc_2_name    = var.subnet_01_secondary_svc_2_name
  subnet_01_secondary_svc_2_range = var.subnet_01_secondary_svc_2_range
  subnet_01_secondary_pod_name    = var.subnet_01_secondary_pod_name
  subnet_01_secondary_pod_range = var.subnet_01_secondary_pod_range
  subnet_02_secondary_svc_1_name    = var.subnet_02_secondary_svc_1_name
  subnet_02_secondary_svc_1_range = var.subnet_02_secondary_svc_1_range
  subnet_02_secondary_svc_2_name    = var.subnet_02_secondary_svc_2_name
  subnet_02_secondary_svc_2_range = var.subnet_02_secondary_svc_2_range
  subnet_02_secondary_pod_name    = var.subnet_02_secondary_pod_name
  subnet_02_secondary_pod_range = var.subnet_02_secondary_pod_range
}
