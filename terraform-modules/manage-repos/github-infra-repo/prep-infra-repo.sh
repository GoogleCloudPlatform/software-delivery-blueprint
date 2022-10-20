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

github_org=${1}
application_name=${2}
github_user=${3}
github_email=${4}
org_id=${5}
billing_account=${6}
state_bucket=${7}
app_factory_project_id=${8}
ci_sa=${9}
cd_sa=${10}
region=${11}
trigger_type=${12}
folder_id=${13}

repo=${application_name}-infra
for branch in "cicd-trigger"
do
  git clone -b ${branch} https://github.com/${github_org}/${repo} ${repo}
  cd ${repo}
  find . -type f -name "*.tf" -exec  sed -i "s/YOUR_BILLING_ACCOUNT/${billing_account}/g" {} +
  find . -type f -name "*.tf" -exec  sed -i "s/YOUR_ORG_ID/${org_id}/g" {} +
  find . -type f -name "*.tf" -exec  sed -i "s/YOUR_GITHUB_USER/${github_user}/g" {} +
  find . -type f -name "*.tf" -exec  sed -i "s/YOUR_GITHUB_EMAIL/${github_email}/g" {} +
  find . -type f -name "*.tf" -exec  sed -i "s/YOUR_GITHUB_ORG/${github_org}/g" {} +
  find . -type f -name "*.tf" -exec  sed -i "s/YOUR_FOLDER_ID/${folder_id}/g" {} +
  find . -type f -name "*.tf" -exec  sed -i "s/YOUR_PROJECT_NAME/${application_name}/g" {} +
  find . -type f -name "*.tf" -exec  sed -i "s/YOUR_TERRAFORM_STATE_BUCKET/${state_bucket}/g" {} +
  find . -type f -name "*.tf" -exec  sed -i "s/YOUR_APPLICATION/${application_name}/g" {} +
  find . -type f -name "*.tf" -exec  sed -i "s:YOUR_CI_SA:${ci_sa}:g" {} +
  find . -type f -name "*.tf" -exec  sed -i "s:YOUR_CD_SA:${cd_sa}:g" {} +
  find . -type f -name "*.tf" -exec  sed -i "s/YOUR_APP_ADMIN_PROJECT/${app_factory_project_id}/g" {} +
  find . -type f -name "*.tf" -exec  sed -i "s/YOUR_REGION/${region}/g" {} +
  find . -type f -name "cloudbuild.yaml" -exec  sed -i "s:YOUR_CI_SA:${ci_sa}:g" {} +
  find . -type f -name "*.tf" -exec  sed -i "s/YOUR_TRIGGER_TYPE/${trigger_type}/g" {} +
  git add .
  git config --global user.name ${github_user}
  git config --global user.email ${github_email}
  git commit -m "Setting up infra repo."
  git push origin
done
