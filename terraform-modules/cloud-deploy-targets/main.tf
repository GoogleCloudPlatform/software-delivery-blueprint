resource "google_clouddeploy_target" "target" {
    location = var.location
    name     = var.name
    gke {
      cluster = var.cluster_name
    }

    require_approval = var.require_approval
    project          = var.project
    execution_configs {
      service_account = var.service_account
      usages          = ["RENDER", "DEPLOY"]
    }
}

//Adding the target to secretmanager
resource "google_secret_manager_secret" "clouddeploy-target" {
  secret_id = var.name
  replication {
    auto {}
  }
  project = var.project
}

resource "google_secret_manager_secret_version" "clouddeploy-target-secret" {
  provider    = google
  secret      = google_secret_manager_secret.clouddeploy-target.id
  secret_data = google_clouddeploy_target.target.name
}
