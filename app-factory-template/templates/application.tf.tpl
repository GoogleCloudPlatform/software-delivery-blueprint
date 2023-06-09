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

data "google_project" "YOUR_APPLICATION_NAME_factory_project" {
  project_id = "YOUR_PROJECT_ID"
}

data "google_project" "YOUR_APPLICATION_NAME_infra_project" {
  project_id = "YOUR_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_github-user" {
  secret = "github-user"
  project = "YOUR_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_github-token" {
  secret = "github-token"
  project = "YOUR_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_github-email" {
  secret = "github-email"
  project = "YOUR_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_github-org" {
  secret = "github-org"
  project = "YOUR_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_acm-repo" {
  secret = "acm-repo"
  project = "YOUR_PROJECT_ID"
}

locals {
    YOUR_APPLICATION_NAME_environments = ["dev", "staging", "prod"]
    YOUR_APPLICATION_NAME_namespace = zipmap(local.YOUR_APPLICATION_NAME_environments,[for env in local.YOUR_APPLICATION_NAME_environments : "YOUR_APPLICATION_NAME"])
    YOUR_APPLICATION_NAME_ksa = zipmap(local.YOUR_APPLICATION_NAME_environments,[for env in local.YOUR_APPLICATION_NAME_environments : "YOUR_APPLICATION_NAME-ksa"])
}

//Create application seed/admin project and cloud build service accounts for iac and cicd
module "YOUR_APPLICATION_NAME-admin-seed" {
  source = "git::https://github.com/GITHUB_ORG_TO_CLONE_TEMPLATES_FROM/terraform-modules.git//app-group-admin-seed"
  app_name = "YOUR_APPLICATION_NAME"
  env = local.YOUR_APPLICATION_NAME_environments
  region = "YOUR_REGION"
  project_id = "YOUR_PROJECT_ID"
}

module "YOUR_APPLICATION_NAME-iac-pipeline" {
  source = "git::https://github.com/GITHUB_ORG_TO_CLONE_TEMPLATES_FROM/terraform-modules.git//manage-repos/github-infra-repo"
  application_name = "YOUR_APPLICATION_NAME"
  org_name_to_clone_template_from = "GITHUB_ORG_TO_CLONE_TEMPLATES_FROM"
  trigger_type = "YOUR_TRIGGER_TYPE"
  project_number = data.google_project.YOUR_APPLICATION_NAME_factory_project.number
  project_id = "YOUR_PROJECT_ID"
  service_account = module.YOUR_APPLICATION_NAME-admin-seed.iac_sa_id
  github_user = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-user.secret_data
  github_email = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-email.secret_data
  state_bucket = module.YOUR_APPLICATION_NAME-admin-seed.iac_bucket_name
  ci_sa  = module.YOUR_APPLICATION_NAME-admin-seed.cicd_sa_id
  region = "YOUR_REGION"
}


module "YOUR_APPLICATION_NAME-lz-dev" {
  source                = "git::https://github.com/GITHUB_ORG_TO_CLONE_TEMPLATES_FROM/terraform-modules.git//landing-zone/dev"
  gsa                   =  module.YOUR_APPLICATION_NAME-admin-seed.workload_gsa["dev"].name
  app_name              = "YOUR_APPLICATION_NAME"
  ksa                   = local.YOUR_APPLICATION_NAME_ksa["dev"]
  project_id            = "YOUR_PROJECT_ID"
  cicd_sa               = module.YOUR_APPLICATION_NAME-admin-seed.cicd_sa_email
  env                   = "dev"
  namespace             = local.YOUR_APPLICATION_NAME_namespace["dev"]
  git_user              = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-user.secret_data
  git_email             = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-email.secret_data
  git_org               = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-org.secret_data
  acm_repo              = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_acm-repo.secret_data
  git_token             = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-token.secret_data
}

module "YOUR_APPLICATION_NAME-lz-staging" {
  source                = "git::https://github.com/GITHUB_ORG_TO_CLONE_TEMPLATES_FROM/terraform-modules.git//landing-zone/staging"
  gsa                   =  module.YOUR_APPLICATION_NAME-admin-seed.workload_gsa["staging"].name
  app_name              = "YOUR_APPLICATION_NAME"
  ksa                   = local.YOUR_APPLICATION_NAME_ksa["staging"]
  project_id            = "YOUR_PROJECT_ID"
  cicd_sa               = module.YOUR_APPLICATION_NAME-admin-seed.cicd_sa_email
  env                   = "staging"
  namespace             = local.YOUR_APPLICATION_NAME_namespace["staging"]
  git_user              = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-user.secret_data
  git_email             = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-email.secret_data
  git_org               = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-org.secret_data
  acm_repo              = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_acm-repo.secret_data
  git_token             = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-token.secret_data
  depends_on            = [module.YOUR_APPLICATION_NAME-lz-dev]
}


module "YOUR_APPLICATION_NAME-lz-prod" {
  source                = "git::https://github.com/GITHUB_ORG_TO_CLONE_TEMPLATES_FROM/terraform-modules.git//landing-zone/prod"
  gsa                   =  module.YOUR_APPLICATION_NAME-admin-seed.workload_gsa["prod"].name
  app_name              = "YOUR_APPLICATION_NAME"
  ksa                   = local.YOUR_APPLICATION_NAME_ksa["prod"]
  project_id            = "YOUR_PROJECT_ID"
  cicd_sa               = module.YOUR_APPLICATION_NAME-admin-seed.cicd_sa_email
  env                   = "prod"
  namespace             = local.YOUR_APPLICATION_NAME_namespace["prod"]
  git_user              = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-user.secret_data
  git_email             = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-email.secret_data
  git_org               = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-org.secret_data
  acm_repo              = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_acm-repo.secret_data
  git_token             = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-token.secret_data
  depends_on            = [module.YOUR_APPLICATION_NAME-lz-staging]
}

module "YOUR_APPLICATION_NAME-cicd-repo" {
  source = "git::https://github.com/GITHUB_ORG_TO_CLONE_TEMPLATES_FROM/terraform-modules.git//manage-repos/github-app-repo"
  application_name = "YOUR_APPLICATION_NAME"
  org_name_to_clone_template_from = "GITHUB_ORG_TO_CLONE_TEMPLATES_FROM"
  trigger_type = "donotcreate" //This is to now create the githubtrigger or webhook with this call. The github trigger or webhook si created by the IaC trigger
  project_number = data.google_project.YOUR_APPLICATION_NAME_factory_project.number
  project_id = "YOUR_PROJECT_ID"
  service_account = module.YOUR_APPLICATION_NAME-admin-seed.iac_sa_id
  app_runtime = "YOUR_APPLICATION_RUNTIME"
  github_user = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-user.secret_data
  github_email = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-email.secret_data
  depends_on = [ module.YOUR_APPLICATION_NAME-lz-dev, module.YOUR_APPLICATION_NAME-lz-staging, module.YOUR_APPLICATION_NAME-lz-prod ]
  namespace = local.YOUR_APPLICATION_NAME_namespace
  ksa = local.YOUR_APPLICATION_NAME_ksa
  env = local.YOUR_APPLICATION_NAME_environments
  region = "YOUR_REGION"
}
