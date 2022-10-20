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
  # The following locals are derived from the subnet object
  node_subnet        = var.subnet.name
  pod_subnet         = var.subnet.secondary_ip_range[0].range_name
  svc_subnet         = var.subnet.secondary_ip_range[local.suffix].range_name
  region             = var.subnet.region
  network            = split("/", var.subnet.network)[length(split("/", var.subnet.network)) - 1]
  network_project_id = var.subnet.project
  suffix             = var.suffix
  env                = var.env
  zone1              = var.zone[0]
  zone2              = var.zone[1]
  zone3              = var.zone[2]
}


module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
  version                    = "23.1.0"
  project_id                 = var.project_id
  name                       = "gke-${local.env}-${local.region}"
  regional                   = false
  region                     = local.region
  zones                      = ["${local.region}-${local.zone1}", "${local.region}-${local.zone2}", "${local.region}-${local.zone3}"]
  release_channel            = "REGULAR"
  network                    = local.network
  subnetwork                 = local.node_subnet
  network_project_id         = local.network_project_id
  ip_range_pods              = local.pod_subnet
  ip_range_services          = local.svc_subnet
  remove_default_node_pool   = true
  horizontal_pod_autoscaling = true
  http_load_balancing        = true
  cluster_resource_labels    = { "environ" : local.env, "region" : local.region }

  node_pools = [
    {
      name           = "node-pool-01"
      machine_type   = "e2-standard-4"
      min_count      = 4
      max_count      = 10
      auto_upgrade   = true
      node_count     = 4
      node_locations = "${local.region}-${local.zone2},${local.region}-${local.zone3}"
    },
  ]
}