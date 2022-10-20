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

variable "parent_team_id" {}

module "YOUR_TEAM_NAME" {

    source = "PATH_TO_MODULE"
    name = "YOUR_TEAM_NAME"
    description = "YOUR_TEAM_DESCRIPTION"
    privacy = "YOUR_TEAM_PRIVACY"
    parent_team_id = PARENT_TEAM_ID
    members = YOUR_TEAM_MEMBERS
    maintainers = YOUR_TEAM_MAINTAINERS
    admin_repositories = ADMIN_REPOSITORIES
    maintain_repositories = MAINTAIN_REPOSITORIES
    push_repositories = PUSH_REPOSITORIES
    triage_repositories = TRIAGE_REPOSITORIES
    pull_repositories = PULL_REPOSITORIES


}

