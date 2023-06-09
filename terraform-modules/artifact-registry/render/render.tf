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

resource "null_resource" "artifact_registry_renderer" {
  //The trigger is set to timestamp as we want the script to refresh LZ everytime tf is run. This will be helpful in cases this script fails and we need to run terraform again.
  //If we do not use timestamp, the script will not execute on tf rerun as it would only run on create.
  //The script handles change conditions gracefully and if it is just a tf run without any changes to AR config files, it will not update the LZ
  triggers = {
    timestamp = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/create_iam_member.sh ${var.git_org} ${var.git_repo} ${var.git_user} ${var.git_email} ${var.service_account_name} ${var.cluster_name}"
  }

  // https://github.com/hashicorp/terraform/issues/23679

}