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
  secret_id = "${var.app_name}-infra-webhook-secret"
  replication {
    auto {}
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

resource "google_cloudbuild_trigger" "deploy-infra" {
  name        = "deploy-infra-${var.app_name}"
  description = "Webhook to deploy the infra"
  project     = var.project_id
  webhook_config {
    secret = google_secret_manager_secret_version.wh-secv.id
  }

  build {
    step {
      id         = "branch-name"
      name       = "gcr.io/cloud-builders/git"
      entrypoint = "sh"
      args = [
        "-c",
        <<-EOF
      branch=`echo "${"$"}{_REF}" | cut -d "/" -f3`
      git clone https://$${github_user}:$${github_token}@github.com/$${github_org}/${"$"}{_REPO}
      cd ${"$"}{_REPO}
      git checkout $branch
      echo "***********************"
      echo "$branch"
      echo "***********************"
  EOF
      ]
      secret_env = [
        "github_user",
        "github_token",
      "github_org"]
    }
    step {
      id         = "tf-init"
      name       = "hashicorp/terraform:1.0.0"
      entrypoint = "sh"
      args = [
        "-c",
        <<-EOF
      branch=`echo "${"$"}{_REF}" | cut -d "/" -f3`
      cd ${"$"}{_REPO}
      git config --global url."https://$$github_user:$$github_token@github.com".insteadOf "https://github.com"
      if [ -d "env/$branch/" ]; then
        cd env/$branch
        terraform init -no-color || exit 1
      else
        for dir in env/*/
        do
          cd ${"$"}{dir}
          env=${"$"}{dir%*/}
          env=${"$"}{env#*/}
          echo ""
          echo "*************** TERRAFORM INIT ******************"
          echo "******* At environment: ${"$"}{env} ********"
          echo "*************************************************"
          terraform init -no-color || exit 1
          cd ../../
        done
      fi
  EOF
      ]
      secret_env = [
        "github_user",
      "github_token"]

    }
    step {
      id         = "tf-plan"
      name       = "hashicorp/terraform:1.0.0"
      entrypoint = "sh"
      args = [
        "-c",
        <<-EOF
      branch=`echo "${"$"}{_REF}" | cut -d "/" -f3`
      cd ${"$"}{_REPO}
      git config --global url."https://$$github_user:$$github_token@github.com".insteadOf "https://github.com"
      if [ -d "env/$branch/" ]; then
        cd env/$branch
        terraform plan -no-color || exit 1
      else
        for dir in env/*/
        do
          cd ${"$"}{dir}
          env=${"$"}{dir%*/}
          env=${"$"}{env#*/}
          echo ""
          echo "*************** TERRAFOM PLAN ******************"
          echo "******* At environment: ${"$"}{env} ********"
          echo "*************************************************"
          terraform plan -no-color || exit 1
          cd ../../
        done
      fi
  EOF
      ]
      secret_env = [
        "github_user",
      "github_token"]
    }
    step {
      id         = "tf-apply"
      name       = "hashicorp/terraform:1.0.0"
      entrypoint = "sh"
      args = [
        "-c",
        <<-EOF
      branch=`echo "${"$"}{_REF}" | cut -d "/" -f3`
      cd ${"$"}{_REPO}
      git config --global url."https://$$github_user:$$github_token@github.com".insteadOf "https://github.com"
      git checkout $branch
      if [ -d "env/$branch/" ]; then
        cd env/$branch
        terraform apply -auto-approve -no-color || exit 1
      else
        echo "***************************** SKIPPING APPLYING *******************************"
        echo "Branch ${"$"}{branch} does not represent an official environment."
        echo "*******************************************************************************"
      fi
  EOF
      ]
      secret_env = [
        "github_user",
      "github_token"]
    }
    available_secrets {
      secret_manager {
        version_name = "projects/$PROJECT_ID/secrets/github-user/versions/latest"
        env          = "github_user"
      }
      secret_manager {
        version_name = "projects/$PROJECT_ID/secrets/github-token/versions/latest"
        env          = "github_token"
      }
      secret_manager {
        version_name = "projects/$PROJECT_ID/secrets/github-org/versions/latest"
        env          = "github_org"
      }
    }

    options {
      logging = "CLOUD_LOGGING_ONLY"
    }
  }
  substitutions = {
    _REPO       = "${var.infra_repo_name}"
    _REF        = "${"$"}(body.ref)"
    _COMMIT_MSG = "${"$"}(body.head_commit.message)"
  }
  filter          = "(!_COMMIT_MSG.matches('IGNORE'))"
  service_account = var.service_account

}


resource "google_apikeys_key" "api-key" {
  name         = "${var.app_name}-infra-webhook-api-key-1"
  display_name = "${var.app_name} Infra webhook API key-1"
  project      = var.project_id
  restrictions {
    api_targets {
      service = "cloudbuild.googleapis.com"
    }
  }
}

resource "github_repository_webhook" "gh-webhook" {
  provider   = github
  repository = "${var.infra_repo_name}"
  configuration {
    url          = "https://cloudbuild.googleapis.com/v1/projects/${var.project_id}/triggers/deploy-infra-${var.app_name}:webhook?key=${google_apikeys_key.api-key.key_string}&secret=${random_password.pass-webhook.result}"
    content_type = "json"
    insecure_ssl = false
  }
  active     = true
  events     = ["push"]
  depends_on = [google_cloudbuild_trigger.deploy-infra]

}
