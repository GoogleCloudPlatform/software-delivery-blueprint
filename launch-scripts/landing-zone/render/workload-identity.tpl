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

module "CLUSTER_PROJECT-CLUSTER_NAME" {
  source           = "../workload-identity"
  gsa              = var.gsa
  gke_project_id   = "CLUSTER_PROJECT"
  app_name         = var.app_name
  ksa              = var.ksa
  cicd_sa          = var.cicd_sa
  env              = var.env
  project_id       = var.project_id
  namespace        = var.namespace
  git_user         = var.git_user
  git_email        = var.git_email
  git_org          = var.git_org
  acm_repo         = var.acm_repo
  git_token        = var.git_token
}

output "CLUSTER_PROJECT-CLUSTER_NAME" {
  value       = module.CLUSTER_PROJECT-CLUSTER_NAME
  description = "The target object that is wrapped up in the module."
}