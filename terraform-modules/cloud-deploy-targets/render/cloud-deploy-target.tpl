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

module "CLUSTER_NAME" {
  source           = "./target"
  name             = "CLUSTER_NAME"
  cluster          = "CLUSTER_PATH"
  require_approval = REQ_APPROVAL
  location         = var.location
  project          = var.project
  service_account  = var.service_account
}

output "CLUSTER_NAME" {
  value       = module.CLUSTER_NAME
  description = "The target object that is wrapped up in the module."
}