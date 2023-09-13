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

// Create admin project
module "admin-project" {
  source                  = "../project-factory"
  random_project_id       = true
  billing_account         = var.billing_account
  name                    = var.project_name
  org_id                  = var.org_id
  folder_id               = var.folder_id
  default_service_account = "keep"
  activate_apis = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudfunctions.googleapis.com",
    "apikeys.googleapis.com"
  ]
}

// Create a new service account for Cloud Build to be used for the IaC pipeline
resource "google_service_account" "iac-sa" {
  count        = var.create_service_account ? 1 : 0
  project      = module.admin-project.project_id
  account_id   = "cloudbuild-iac"
  display_name = "Cloud Build - Infra as Code service account"
}

// Grant project level roles to the Cloud Build SA for IaC pipeline
resource "google_project_iam_member" "iac-sa-cloudbuild-roles" {
  project = module.admin-project.project_id
  for_each = toset([
    "roles/cloudbuild.builds.builder",
    "roles/logging.logWriter",
    "roles/owner"
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.iac-sa[0].email}"
}

resource "google_storage_bucket" "iac-state-bucket" {
  name                        = join("-", [module.admin-project.project_id, "infra-tf"])
  project                     = module.admin-project.project_id
  location                    = var.region
  storage_class               = null
  uniform_bucket_level_access = true
  labels                      = null
  force_destroy               = true
}

resource "google_storage_bucket_iam_member" "bucket-members-2" {
  bucket = google_storage_bucket.iac-state-bucket.name
  for_each = toset([
    "roles/storage.objectCreator",
    "roles/storage.objectViewer",
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.iac-sa[0].email}"
}
// Create a new service account for Cloud Build to be used for the application CI/CD pipeline
resource "google_service_account" "cicd-sa" {
  count        = var.create_service_account ? 1 : 0
  project      = module.admin-project.project_id
  account_id   = "cloudbuild-cicd"
  display_name = "Cloud Build - CI/CD service account"
}

resource "google_project_iam_member" "cicd-sa-cloudbuild" {
  project = module.admin-project.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_service_account.cicd-sa[0].email}"
}

resource "google_project_iam_member" "cicd-sa-cloudbuild-roles" {
  project = module.admin-project.project_id
  for_each = toset([
    "roles/serviceusage.serviceUsageAdmin",
    "roles/clouddeploy.operator",
    "roles/cloudbuild.builds.builder",
    "roles/secretmanager.secretAccessor",
    "roles/secretmanager.admin",
    "roles/serviceusage.apiKeysAdmin",
    "roles/storage.admin",
    "roles/artifactregistry.writer"
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.cicd-sa[0].email}"
}

//Create SA for cloud deploy
resource "google_service_account" "cloud-deploy" {
  count        = var.create_service_account ? 1 : 0
  project      = module.admin-project.project_id
  account_id   = "clouddeploy"
  display_name = "Cloud Deploy service account"
}

//Permission cloud deploy SA
resource "google_project_iam_member" "cloud-deploy-roles" {
  project = module.admin-project.project_id
  for_each = toset([
    "roles/logging.logWriter",
    "roles/clouddeploy.jobRunner",
    "roles/storage.objectViewer"
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.cloud-deploy[0].email}"
}

//Add the cloud deploy account to secretmanager so the cicd pipelines can pull and use it.
//Also provide access to Cloud Build cicd service account to look up that secret.
resource "google_secret_manager_secret" "clouddeploy-sa" {
  secret_id = "clouddeploy-sa"
  replication {
    automatic = true
  }
  project = module.admin-project.project_id
}

resource "google_secret_manager_secret_version" "clouddeploy-sa-secret" {
  provider    = google
  secret      = google_secret_manager_secret.clouddeploy-sa.id
  secret_data = "${google_service_account.cloud-deploy[0].email}"
}

resource "google_secret_manager_secret_iam_member" "clouddeploy-sa-secret-access" {
  provider  = google
  secret_id = google_secret_manager_secret.clouddeploy-sa.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.iac-sa[0].email}"
}

# Add CloudDeploy SA to GCS so the Cloud Function can provide it roles to deploy to GKE
resource "google_storage_bucket_object" "gke-deploy" {
  count = length(var.trigger_buckets_dep)
  name   = "${var.app_name}-CloudDeploy-SA.txt"
  content = google_service_account.cloud-deploy[0].email
  bucket = var.trigger_buckets_dep[count.index]
}
resource "time_sleep" "wait_20_seconds_1" {
  create_duration = "20s"
  depends_on = [google_storage_bucket_object.gke-deploy]
}

# Add CloudDeploy SA to GCS so the Cloud Function can provide it roles to use connect gateway
resource "google_storage_bucket_object" "gkehub-connect" {
  count = length(var.trigger_bucket_connect)
  name   = "${var.app_name}-CloudDeploy-SA.txt"
  content = google_service_account.cloud-deploy[0].email
  bucket = var.trigger_bucket_connect[count.index]
  depends_on = [time_sleep.wait_20_seconds_1]
}

resource "time_sleep" "wait_20_seconds_4" {
  create_duration = "20s"
  depends_on = [google_storage_bucket_object.gkehub-connect]
}

# Add default Cloud Build SA to GCS so the Cloud Function can provide it roles to use private pool
# need acess to only dev private pool since CB only be running the builds and not deployments.
resource "google_storage_bucket_object" "private-pool-cb" {
  count = length(var.trigger_bucket_pool)
  name   = "${var.app_name}-CloudBuild-Default-SA.txt"
  content = format("%s@cloudbuild.gserviceaccount.com", module.admin-project.project_number)
  bucket = var.trigger_bucket_pool[count.index]
  depends_on = [time_sleep.wait_20_seconds_4]
}

resource "time_sleep" "wait_20_seconds_5" {
  create_duration = "20s"
  depends_on = [google_storage_bucket_object.private-pool-cb]
}

# Add Cloud Deploy service agent to GCS so the Cloud Function can provide it roles to use private pool
resource "google_storage_bucket_object" "private-pool-cd" {
  count = length(var.trigger_bucket_pool)
  name   = "${var.app_name}-CloudDeploy-Serive-Agent.txt"
  content = format("service-%s@gcp-sa-clouddeploy.iam.gserviceaccount.com", module.admin-project.project_number)
  bucket = var.trigger_bucket_pool[count.index]
  depends_on = [time_sleep.wait_20_seconds_5]
}

# Add IaC and CICD SA to GCS so Cloud Function can provide it secret read roles
resource "google_storage_bucket_object" "secret-read-iac" {
  name   = "${var.app_name}-IaC-SA.txt"
  content = google_service_account.iac-sa[0].email
  bucket = var.trigger_bucket_sec
}
resource "time_sleep" "wait_20_seconds_2" {
  create_duration = "20s"
  depends_on = [google_storage_bucket_object.secret-read-iac]
}
resource "google_storage_bucket_object" "secret-read-cicd" {
  name   = "${var.app_name}-CICD-SA.txt"
  content = google_service_account.cicd-sa[0].email
  bucket = var.trigger_bucket_sec
  depends_on = [time_sleep.wait_20_seconds_2]
}

# Add IaC SA to GCS so Cloud Function can provide it billing and project creator roles
resource "google_storage_bucket_object" "billing-user-iac" {
  name   = "${var.app_name}-IaC-SA.txt"
  content = google_service_account.iac-sa[0].email
  bucket = var.trigger_bucket_billing
  depends_on = [google_storage_bucket_object.secret-read-cicd]
}

resource "time_sleep" "wait_20_seconds_3" {
  create_duration = "20s"
  depends_on = [google_storage_bucket_object.billing-user-iac]
}

resource "google_storage_bucket_object" "project-creator-iac" {
  name   = "${var.app_name}-IaC-SA.txt"
  content = google_service_account.iac-sa[0].email
  bucket = var.trigger_bucket_proj
  depends_on = [time_sleep.wait_20_seconds_3]
}


//Allow Cloud Build IaC to impersonate cloud deploy SA to do the deployment
//TODO : not needed
//resource "google_service_account_iam_member" "iac-sa-impersonate-cd" {
//  service_account_id = google_service_account.cloud-deploy[0].name
//  role               = "roles/iam.serviceAccountUser"
//  member             = "serviceAccount:${google_service_account.iac-sa[0].email}"
//}

//Allow Cloud Build IaC SA to impersonate Cloud Build CICD SA so the former can create a cloud build trigger and attach the latter to it,
resource "google_service_account_iam_member" "iac-sa-impersonate-cicd" {
  service_account_id = google_service_account.cicd-sa[0].name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.iac-sa[0].email}"
}

//Allow Cloud Build CICD to impersonate cloud deploy SA to do the deployment
resource "google_service_account_iam_member" "cicd-sa-impersonate-cd" {
  service_account_id = google_service_account.cloud-deploy[0].name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.cicd-sa[0].email}"
}

// Create new service accounts per environment for workload identity
locals {
  wi_roles = ["roles/secretmanager.secretAccessor", "roles/secretmanager.admin", "roles/storage.objectCreator", "roles/storage.objectViewer", "roles/storage.admin"]
  wi_roles_perm_combo = [
    for pair in setproduct(local.wi_roles, var.env) : {
      role        = pair[0]
      member      = "serviceAccount:${google_service_account.workload-identity-sa[pair[1]].email}"
      environment = pair[1]
    }
  ]
  wi_roles_mapping = {
    for m in local.wi_roles_perm_combo : "${m.role} ${m.environment}" => m
  }
}
// Create a new service account for workload identity
resource "google_service_account" "workload-identity-sa" {
  for_each     = toset(var.env)
  project      = module.admin-project.project_id
  account_id   = "${each.key}-wi-${var.app_name}"
  display_name = "Workload Identity SA for ${each.key} environment"
}

// Grant project level roles to the workload identity SA
resource "google_project_iam_member" "workload-identity-sa-roles" {
  project  = module.admin-project.project_id
  for_each = local.wi_roles_mapping
  role     = each.value.role
  member   = each.value.member
}

//Following section creates new secrets in application seed/admin project
resource "google_secret_manager_secret" "app-name" {
  secret_id = "app-name"
  replication {
    automatic = true
  }
  project = module.admin-project.project_id
}
resource "google_secret_manager_secret_version" "app-name-secret" {
  secret      = google_secret_manager_secret.app-name.id
  secret_data = var.app_name
}

resource "google_secret_manager_secret_iam_member" "app-name-secret-access" {
  secret_id = google_secret_manager_secret.app-name.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cicd-sa[0].email}"
}

resource "google_secret_manager_secret" "region" {
  secret_id = "region"
  replication {
    automatic = true
  }
  project = module.admin-project.project_id
}
resource "google_secret_manager_secret_version" "region-secret" {
  secret      = google_secret_manager_secret.region.id
  secret_data = var.region
}

resource "google_secret_manager_secret_iam_member" "region-secret-access" {
  secret_id = google_secret_manager_secret.region.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cicd-sa[0].email}"
}