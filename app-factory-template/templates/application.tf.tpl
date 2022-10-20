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
  project_id = "YOUR_SEED_PROJECT_ID"
}

data "google_project" "YOUR_APPLICATION_NAME_infra_project" {
  project_id = "YOUR_INFRA_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_github-user" {
  secret = "github-user"
  project = "YOUR_INFRA_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_github-token" {
  secret = "github-token"
  project = "YOUR_INFRA_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_github-email" {
  secret = "github-email"
  project = "YOUR_INFRA_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_gcp-billingac" {
  secret = "gcp-billingac"
  project = "YOUR_INFRA_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_github-org" {
  secret = "github-org"
  project = "YOUR_INFRA_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_gcp-org" {
  secret = "gcp-org"
  project = "YOUR_INFRA_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_gcp-folder" {
  secret = "gcp-folder"
  project = "YOUR_INFRA_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_group-id" {
  secret = "group-id"
  project = "YOUR_INFRA_PROJECT_ID"
}

data "google_secret_manager_secret_version" "YOUR_APPLICATION_NAME_acm-repo" {
  secret = "acm-repo"
  project = "YOUR_INFRA_PROJECT_ID"
}

locals {
    YOUR_APPLICATION_NAME_environments = ["dev", "staging", "prod"]
    YOUR_APPLICATION_NAME_namespace = zipmap(local.YOUR_APPLICATION_NAME_environments,[for env in local.YOUR_APPLICATION_NAME_environments : "YOUR_APPLICATION_NAME"])
    YOUR_APPLICATION_NAME_ksa = zipmap(local.YOUR_APPLICATION_NAME_environments,[for env in local.YOUR_APPLICATION_NAME_environments : "YOUR_APPLICATION_NAME-ksa"])
}

//Create application seed/admin project and cloud build service accounts for iac and cicd
module "YOUR_APPLICATION_NAME-admin-seed" {
  source = "git::https://github.com/GITHUB_ORG_TO_CLONE_TEMPLATES_FROM/terraform-modules.git//app-group-admin-seed"
  project_name = "YOUR_APP_PROJECT"
  billing_account = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_gcp-billingac.secret_data
  org_id = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_gcp-org.secret_data
  folder_id = "YOUR_GCP_FOLDER_ID" //Not passing the folder id from the secret gcp-folder in multi-tenant project to allow the teams to create applications in separate folder if needed.
  app_factory_cb_service_account = format("%s@%s",data.google_project.YOUR_APPLICATION_NAME_factory_project.number,"cloudbuild.gserviceaccount.com")
  group_id = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_group-id.secret_data
  app_name = "YOUR_APPLICATION_NAME"
  custom_sa = "YOUR_SA_TO_IMPERSONATE"
  env = local.YOUR_APPLICATION_NAME_environments
  region = "YOUR_REGION"
  providers = { google.impersonated = google.impersonated }
}

//Copy the secrets from multi-tenant infra/platform project to the application seed/admin project
module "YOUR_APPLICATION_NAME-copy-secrets" {
  source = "git::https://github.com/GITHUB_ORG_TO_CLONE_TEMPLATES_FROM/terraform-modules.git//app-group-copy-secrets"
  secrets = ["github-user", "github-email", "github-token", "gcp-billingac", "github-org", "gcp-org", "gcp-folder"]
  infra_project_id = "YOUR_INFRA_PROJECT_ID"
  seed_project_id = module.YOUR_APPLICATION_NAME-admin-seed.project_id
  cb_iac_service_account = module.YOUR_APPLICATION_NAME-admin-seed.iac_sa_email
  app_name = "YOUR_APPLICATION_NAME"
  region   = "YOUR_REGION"
}

module "YOUR_APPLICATION_NAME-iac-pipeline" {
  source = "git::https://github.com/GITHUB_ORG_TO_CLONE_TEMPLATES_FROM/terraform-modules.git//manage-repos/github-infra-repo"
  application_name = "YOUR_APPLICATION_NAME"
  org_name_to_clone_template_from = "GITHUB_ORG_TO_CLONE_TEMPLATES_FROM"
  trigger_type = "YOUR_TRIGGER_TYPE"
  project_number = module.YOUR_APPLICATION_NAME-admin-seed.project_number
  project_id = module.YOUR_APPLICATION_NAME-admin-seed.project_id
  service_account = module.YOUR_APPLICATION_NAME-admin-seed.iac_sa_id
  app_runtime = "YOUR_APPLICATION_RUNTIME"
  github_user = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-user.secret_data
  github_email = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_github-email.secret_data
  org_id = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_gcp-org.secret_data
  billing_account = data.google_secret_manager_secret_version.YOUR_APPLICATION_NAME_gcp-billingac.secret_data
  state_bucket = module.YOUR_APPLICATION_NAME-admin-seed.iac_bucket_name
  depends_on = [module.YOUR_APPLICATION_NAME-copy-secrets]
  ci_sa  = module.YOUR_APPLICATION_NAME-admin-seed.cicd_sa_id
  cd_sa = module.YOUR_APPLICATION_NAME-admin-seed.clouddeploy_sa_email
  region = "YOUR_REGION"
  folder_id = "YOUR_GCP_FOLDER_ID" //Not passing the folder id from the secret gcp-folder in multi-tenant project to allow the teams to create applications in separate folder if needed.
}


module "YOUR_APPLICATION_NAME-lz-dev" {
  source                = "git::https://github.com/GITHUB_ORG_TO_CLONE_TEMPLATES_FROM/terraform-modules.git//landing-zone/dev"
  gsa                   =  module.YOUR_APPLICATION_NAME-admin-seed.workload_gsa["dev"].name
  app_name              = "YOUR_APPLICATION_NAME"
  ksa                   = local.YOUR_APPLICATION_NAME_ksa["dev"]
  project_id            = module.YOUR_APPLICATION_NAME-admin-seed.project_id
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
  project_id            = module.YOUR_APPLICATION_NAME-admin-seed.project_id
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
  project_id            = module.YOUR_APPLICATION_NAME-admin-seed.project_id
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
  project_number = module.YOUR_APPLICATION_NAME-admin-seed.project_number
  project_id = module.YOUR_APPLICATION_NAME-admin-seed.project_id
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
