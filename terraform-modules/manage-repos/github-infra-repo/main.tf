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


resource "github_repository" "infrastructure_repo" {
  name                   = "${var.application_name}-infra"
  description            = "Infrastructure as code repository for ${var.application_name}"
  visibility             = "private"
  has_issues             = false
  has_projects           = false
  has_wiki               = false
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  delete_branch_on_merge = false
  vulnerability_alerts   = true
  template {
    owner      = "${var.org_name_to_clone_template_from}"
    repository = "infra-template"
  }
}

resource "github_branch" "infrastructure_repo_dev" {
  repository    = github_repository.infrastructure_repo.name
  source_branch = "cicd-trigger"
  branch        = "dev"
  depends_on    = [github_repository.infrastructure_repo]
}

resource "github_branch" "infrastructure_repo_staging" {
  repository    = github_repository.infrastructure_repo.name
  source_branch = "cicd-trigger"
  branch        = "staging"
  depends_on    = [github_repository.infrastructure_repo]
}

resource "github_branch" "infrastructure_repo_prod" {
  repository    = github_repository.infrastructure_repo.name
  source_branch = "cicd-trigger"
  branch        = "prod"
  depends_on    = [github_repository.infrastructure_repo]
}

resource "github_branch_protection_v3" "infrastructure_repo-prt-1" {
  repository = github_repository.infrastructure_repo.name
  branch     = "dev"
  required_pull_request_reviews {
    required_approving_review_count = 1
    require_code_owner_reviews      = true
  }
  restrictions {

  }

  depends_on = [github_branch.infrastructure_repo_dev]
}

resource "github_branch_protection_v3" "infrastructure_repo-prt-2" {
  repository = github_repository.infrastructure_repo.name
  branch     = "staging"
  required_pull_request_reviews {
    required_approving_review_count = 1
    require_code_owner_reviews      = true
  }
  restrictions {

  }

  depends_on = [github_branch.infrastructure_repo_staging]
}

resource "github_branch_protection_v3" "infrastructure_repo-prt-3" {
  repository = github_repository.infrastructure_repo.name
  branch     = "prod"
  required_pull_request_reviews {
    required_approving_review_count = 1
    require_code_owner_reviews      = true
  }
  restrictions {

  }

  depends_on = [github_branch.infrastructure_repo_prod]
}

resource "null_resource" "set-repo" {
  triggers = {
    id = github_repository.infrastructure_repo.id
  }
  provisioner "local-exec" {
    command = "${path.module}/prep-infra-repo.sh ${var.org_name_to_clone_template_from} ${var.application_name} ${var.github_user} ${var.github_email} ${var.state_bucket} ${var.project_id} ${var.ci_sa} ${var.region} ${var.trigger_type}"
  }
  depends_on = [github_repository.infrastructure_repo, github_branch.infrastructure_repo_prod, github_branch.infrastructure_repo_staging ]
}

module "infra-web-hook" {
  count           = var.trigger_type == "webhook" ? 1 : 0
  source          = "../../webhooks/iac"
  app_name        = var.application_name
  project_number  = var.project_number
  infra_repo_name = split("/", github_repository.infrastructure_repo.full_name)[1]
  project_id      = var.project_id
  service_account = var.service_account
  depends_on      = [github_repository.infrastructure_repo,null_resource.set-repo]
}

module "infra-github-trigger" {
  count           = var.trigger_type == "github" ? 1 : 0
  source          = "../../github-triggers/iac"
  project_id      = var.project_id
  service_account = var.service_account
  github_org      = var.org_name_to_clone_template_from
  app_name        = var.application_name
  depends_on      = [github_repository.infrastructure_repo,null_resource.set-repo]
}
