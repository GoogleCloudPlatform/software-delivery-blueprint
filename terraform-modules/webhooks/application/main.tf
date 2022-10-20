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

resource "random_password" "pass-webhook" {
  length  = 16
  special = false
}

resource "google_secret_manager_secret" "wh-sec" {
  project   = var.project_id
  secret_id = "${var.app_name}-app-webhook-secret"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "wh-secv" {
  secret      = google_secret_manager_secret.wh-sec.id
  secret_data = "${random_password.pass-webhook.result}"
}

data "google_iam_policy" "wh-secv-access" {
  binding {
    role = "roles/secretmanager.secretAccessor"
    members = [
      "serviceAccount:service-${var.project_number}@gcp-sa-cloudbuild.iam.gserviceaccount.com",
    ]
  }
}

resource "google_secret_manager_secret_iam_policy" "policy" {
  project     = var.project_id
  secret_id   = google_secret_manager_secret.wh-sec.id
  policy_data = data.google_iam_policy.wh-secv-access.policy_data
}

resource "google_cloudbuild_trigger" "deploy-app" {
  name        = "deploy-app-${var.app_name}"
  description = "Webhook to deploy the app"
  project     = var.project_id
  webhook_config {
    secret = google_secret_manager_secret_version.wh-secv.id
  }

  build {
    step {
      name       = "gcr.io/cloud-builders/git"
      id         = "update-config-repo"
      entrypoint = "bash"
      args = [
        "-c",
        <<-EOF
      branch=`echo "${"$"}{_REF}" | cut -d "/" -f3`
    
      echo ${"$"}{_REPO}
      echo "###########"
      echo $branch
      echo "###########"
      
      git clone -b ${"$"}{branch} https://$$GITHUB_USER:$$GITHUB_TOKEN@github.com/$$GITHUB_ORG/${"$"}{_REPO}
  EOF
      ]
      secret_env = [
        "GITHUB_USER",
        "GITHUB_TOKEN",
      "GITHUB_ORG"]
    }

    step {
      name       = "gcr.io/k8s-skaffold/skaffold"
      id         = "skaffold-build"
      entrypoint = "bash"
      args = [
        "-c",
        <<-EOF
      cd ${"$"}{_REPO}
      skaffold build --file-output=/workspace/artifacts.json \
                           --default-repo $$REGION-docker.pkg.dev/$PROJECT_ID/$$APP_NAME/image-$$APP_NAME-$(date '+%Y%m%d%H%M%S') \
                           --push=true
  EOF
      ]
      secret_env = ["APP_NAME", "REGION"]
    }

    step {
      name       = "gcr.io/cloud-builders/gcloud"
      id         = "create-release"
      entrypoint = "sh"
      args = [
        "-c",
        <<-EOF
      gcloud config set deploy/region $$REGION
      cd ${"$"}{_REPO}
      gcloud beta deploy releases create "release-pipeline-$(date '+%Y%m%d%H%M%S')" --delivery-pipeline=$$APP_NAME --description="First Release" --build-artifacts=/workspace/artifacts.json --annotations="release-id=rel-$(date '+%Y%m%d%H%M%S')"
  EOF
      ]
      secret_env = [
      "APP_NAME", "REGION"]
    }
    available_secrets {
      secret_manager {
        version_name = "projects/$PROJECT_ID/secrets/app-name/versions/latest"
        env          = "APP_NAME"
      }
      secret_manager {
        version_name = "projects/$PROJECT_ID/secrets/github-user/versions/latest"
        env          = "GITHUB_USER"
      }
      secret_manager {
        version_name = "projects/$PROJECT_ID/secrets/github-token/versions/latest"
        env          = "GITHUB_TOKEN"
      }
      secret_manager {
        version_name = "projects/$PROJECT_ID/secrets/github-org/versions/latest"
        env          = "GITHUB_ORG"
      }
      secret_manager {
        version_name = "projects/$PROJECT_ID/secrets/region/versions/latest"
        env          = "REGION"
      }

    }

    options {
      logging = "CLOUD_LOGGING_ONLY"
    }
  }
  substitutions = {
    _REPO       = "${var.app_repo_name}"
    _REF        = "${"$"}(body.ref)"
    _COMMIT_MSG = "${"$"}(body.head_commit.message)"
  }
  filter          = "(!_COMMIT_MSG.matches('IGNORE'))"
  service_account = var.service_account
  depends_on      = [google_secret_manager_secret_version.wh-secv]

}

resource "google_apikeys_key" "api-key" {
  name         = "${var.app_name}-app-webhook-api-key-11"
  display_name = "${var.app_name} App webhook API key-11"
  project      = var.project_id
  restrictions {
    api_targets {
      service = "cloudbuild.googleapis.com"
    }
  }
}

resource "github_repository_webhook" "gh-webhook" {
  provider   = github
  repository = "${var.app_repo_name}"
  configuration {
    url          = "https://cloudbuild.googleapis.com/v1/projects/${var.project_id}/triggers/deploy-app-${var.app_name}:webhook?key=${google_apikeys_key.api-key.key_string}&secret=${random_password.pass-webhook.result}"
    content_type = "json"
    insecure_ssl = false
  }
  active     = true
  events     = ["push"]
  depends_on = [google_cloudbuild_trigger.deploy-app]
}
