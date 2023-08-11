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

//Create app repo
resource "github_repository" "application_repo" {
  name        = var.application_name
  description = "Application code repository for ${var.application_name}"

  visibility   = "private"
  has_issues   = false
  has_projects = false
  has_wiki     = false

  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  delete_branch_on_merge = false

  vulnerability_alerts = true
  template {
    owner      = "${var.org_name_to_clone_template_from}"
    repository = "app-template-${var.app_runtime}"
  }
}

resource "null_resource" "set-repo" {
  count = length(var.env)
  triggers = {
    id = github_repository.application_repo.id
  }
  provisioner "local-exec" {
    command = "${path.module}/prep-app-repo.sh ${var.org_name_to_clone_template_from} ${var.application_name} ${var.github_user} ${var.github_email} ${var.namespace[var.env[count.index]]} ${var.app_suffix} ${var.env[count.index]} ${count.index} ${var.region} ${var.secret_project_id}"
  }
  depends_on = [github_repository.application_repo, module.app-github-trigger, module.app-web-hook]
}

//Create Cloud Build webhook trigger
module "app-web-hook" {
  count           = var.trigger_type == "webhook" ? 1 : 0
  source          = "../../webhooks/application"
  app_name        = var.application_name
  project_number  = var.project_number
  app_repo_name   = split("/", github_repository.application_repo.full_name)[1]
  project_id      = var.project_id
  service_account = var.service_account
  secret_project_id = var.secret_project_id
  depends_on      = [github_repository.application_repo]
}

//Create github webhook to invoke Cloud Build trigger
module "app-github-trigger" {
  count           = var.trigger_type == "github" ? 1 : 0
  source          = "../../github-triggers/application"
  project_id      = var.project_id
  service_account = var.service_account
  github_org      = var.org_name_to_clone_template_from
  app_name        = var.application_name
  depends_on      = [github_repository.application_repo]
}
