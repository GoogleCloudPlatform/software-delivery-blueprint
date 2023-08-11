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

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "5.2.0"

  project_id   = var.project_id
  network_name = var.network_name
  routing_mode = var.routing_mode

  subnets = [
    {
      subnet_name      = var.subnet_01_name
      subnet_ip        = var.subnet_01_ip
      subnet_region    = var.subnet_01_region
      subnet_flow_logs = "true"
      description      = var.subnet_01_description
    },
    {
      subnet_name      = var.subnet_02_name
      subnet_ip        = var.subnet_02_ip
      subnet_region    = var.subnet_02_region
      subnet_flow_logs = "true"
      description      = var.subnet_02_description
    },
  ]

  secondary_ranges = {
    "${var.subnet_01_name}" = [
      {
        range_name    = var.subnet_01_secondary_svc_1_name
        ip_cidr_range = var.subnet_01_secondary_svc_1_range
      },
      {
        range_name    = var.subnet_01_secondary_svc_2_name
        ip_cidr_range = var.subnet_01_secondary_svc_2_range
      },
      {
        range_name    = var.subnet_01_secondary_pod_name
        ip_cidr_range = var.subnet_01_secondary_pod_range
      },
    ]
    "${var.subnet_02_name}" = [
      {
        range_name    = var.subnet_02_secondary_svc_1_name
        ip_cidr_range = var.subnet_02_secondary_svc_1_range
      },
      {
        range_name    = var.subnet_02_secondary_svc_2_name
        ip_cidr_range = var.subnet_02_secondary_svc_2_range
      },
      {
        range_name    = var.subnet_02_secondary_pod_name
        ip_cidr_range = var.subnet_02_secondary_pod_range
      },
    ]
  }
}
