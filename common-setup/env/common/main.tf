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

module "deploy-secrets-cloud-function" {
  source                = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//cloud-functions/grant-secret-access"
  project_id            = var.secrets_project_id
  function_name         = "add-secret-permission"
  function_gcs          = "add-secret-permission-src"
  trigger_gcs           = "add-secret-permission-trg"
  region                = var.region
  app_factory_project   = var.app_factory_project_num
}

module "deploy-billing-cloud-function" {
  source                = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//cloud-functions/grant-billing-access"
  project_id            = var.infra_project_id
  function_name         = "add-billing-permission"
  function_gcs          = "add-billing-permission-src"
  trigger_gcs           = "add-billing-permission-trg"
  region                = var.region
  app_factory_project   = var.app_factory_project_num
  secrets_project_id    = var.secrets_project_id
}

module "deploy-project-cloud-function" {
  source                = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//cloud-functions/grant-project-access"
  project_id            = var.infra_project_id
  function_name         = "add-project-permission"
  function_gcs          = "add-project-permission-src"
  trigger_gcs           = "add-project-permission-trg"
  region                = var.region
  app_factory_project   = var.app_factory_project_num
  secrets_project_id    = var.secrets_project_id
}

module "cloudbuild-private-pool" {
  source = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//cloudbuild-private-pool"
  project_id                = var.infra_project_id
  network_project_id        = var.infra_project_id
  location                  = var.region
  worker_pool_name          = "multi-tenant-private-worker-pool"
  create_cloudbuild_network = true
  private_pool_vpc_name     = "multi-tenant-cloudbuild-peered-vpc"
  worker_address            = "10.37.0.0"
  worker_range_name         = "gke-private-pool-worker-range"
  store_to_secret_mngr      = true
  secret_name               = "multi-tenant-private-pool"
  secret_project_id         = var.secrets_project_id
}