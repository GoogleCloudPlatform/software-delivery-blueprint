#!/bin/sh

# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

github_user={1}
github_token=${2}
acm-repo=${3}
app_name=${4}
gsa=${5}

git config --global url."https://${github_user}:${github_token}@github.com".insteadOf "https://github.com"
git clone -b dev https://${github_user}:${github_token}@github.com/${github_org}/${acm-repo}
if [ ! -d "${acm-repo}/manifests/apps/${app_name}" ]; then
  mkdir -p ${acm-repo}/manifests/apps/${app_name}
  cp ${acm-repo}/templates/_namespace-template/* ${acm-repo}/manifests/apps/${app_name}/
  cd ${acm-repo}/manifests/apps/${app_name}
  sed -ri  "s/APP_NAME/${app_name}/g" *
  sed -ri  "s/YOUR_GSA/${gsa}/g" *
  git config --global user.name ${github_user}
  git config --global user.email ${github_email}
  git add ${acm-repo}/manifests/apps/${app_name}
  git commit -m "Creating namespace and Service account for application ${app_name}"
  git push origin HEAD:dev
  sleep 30
fi
