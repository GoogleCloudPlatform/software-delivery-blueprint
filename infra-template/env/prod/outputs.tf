/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

output "project" {
  value       = module.create-gcp-project.project
  description = "The full host project info"
}

output "project_id" {
  value       = module.create-gcp-project.project.project_id
  description = "The ID of the created project"
}


output "project_number" {
  value       = module.create-gcp-project.project.project_number
  description = "The ID of the created project"
}

output "vpc_network" {
  value       = module.create-vpc.network
  description = "The created network"
}


output "subnets" {
  value       = module.create-vpc.network.subnets
  description = "A map with keys of form subnet_region/subnet_name and values being the outputs of the google_compute_subnetwork resources used to create corresponding subnets."
}

output "network_name" {
  value       = module.create-vpc.network.network_name
  description = "The name of the VPC being created"
}

output "network_self_link" {
  value       = module.create-vpc.network.network_self_link
  description = "The URI of the VPC being created"
}


output "subnets_names" {
  value       = [module.create-vpc.network.subnets_names]
  description = "The names of the subnets being created"
}

output "subnets_ids" {
  value       = [for item in module.create-vpc.network.subnets : item.id]
  description = "The IDs of the subnets being created"
}

output "subnets_ips" {
  value       = [module.create-vpc.network.subnets_ips]
  description = "The IPs and CIDRs of the subnets being created"
}

output "subnets_self_links" {
  value       = [module.create-vpc.network.subnets_self_links]
  description = "The self-links of subnets being created"
}

output "subnets_regions" {
  value       = [module.create-vpc.network.subnets_regions]
  description = "The region where the subnets will be created"
}

output "subnets_private_access" {
  value       = [module.create-vpc.network.subnets_private_access]
  description = "Whether the subnets will have access to Google API's without a public IP"
}

output "subnets_flow_logs" {
  value       = [module.create-vpc.network.subnets_flow_logs]
  description = "Whether the subnets will have VPC flow logs enabled"
}

output "subnets_secondary_ranges" {
  value       = [module.create-vpc.network.subnets_secondary_ranges]
  description = "The secondary ranges associated with these subnets"
}

output "route_names" {
  value       = [module.create-vpc.network.route_names]
  description = "The route names associated with this VPC"
}

