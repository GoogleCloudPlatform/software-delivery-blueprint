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

resource "github_team" "team" {
  name           = var.name
  description    = var.description
  privacy        = var.privacy
  parent_team_id = var.parent_team_id

  depends_on = [var.module_depends_on]
}

locals {
  maintainers = { for i in var.maintainers : lower(i) => { role = "maintainer", username = i } }
  members     = { for i in var.members : lower(i) => { role = "member", username = i } }

  memberships = merge(local.maintainers, local.members)
}

resource "github_team_membership" "team_membership" {
  for_each = local.memberships

  team_id  = github_team.team.id
  username = each.value.username
  role     = each.value.role

  depends_on = [var.module_depends_on]
}

locals {
  repo_admin    = { for i in var.admin_repositories : lower(i) => { permission = "admin", repository = i } }
  repo_maintain = { for i in var.maintain_repositories : lower(i) => { permission = "maintain", repository = i } }
  repo_push     = { for i in var.push_repositories : lower(i) => { permission = "push", repository = i } }
  repo_triage   = { for i in var.triage_repositories : lower(i) => { permission = "triage", repository = i } }
  repo_pull     = { for i in var.pull_repositories : lower(i) => { permission = "pull", repository = i } }

  repositories = merge(local.repo_admin, local.repo_maintain, local.repo_push, local.repo_triage, local.repo_pull)
}

resource "github_team_repository" "team_repository" {
  for_each = local.repositories

  repository = each.value.repository
  team_id    = github_team.team.id
  permission = each.value.permission

  depends_on = [var.module_depends_on]
}