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

resource "null_resource" "landing_zone_renderer" {
  triggers = {
    timestamp = timestamp()
  }
  provisioner "local-exec" {
    when    = create
    command = "${path.module}/create_wi.sh ${var.git_org} ${var.git_user} ${var.git_email} ${var.tf_modules_repo} ${var.cluster_name} ${var.cluster_project_id} ${var.env} ${var.index}"
  }

  // https://github.com/hashicorp/terraform/issues/23679
  //provisioner "local-exec" {
  //  when = destroy
  //  command = "${path.module}/create_target.sh ${var.git_org} ${var.git_repo} ${var.git_user} ${var.git_email} ${var.cluster_name}"
  //}
}
