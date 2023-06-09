#!/bin/bash

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

app_runtime=${1}
app_name=${2}
sa_to_impersonate=${3}
infra_project_id=${4}
user=${5}
email="${user}@github.com"
seed_project_id=${6}
folder_id=${7}
github_org_to_clone_templates_from=${8}
repo=${9}
trigger_type=${10}
github_team=${11}
region=${12}
cd ${repo}

if [ -z $(find apps -maxdepth 1 -type d -name ${app_runtime}) ]; then
  echo "${app_runtime} folder not found under apps. Please add ${app_runtime} to app_runtimes_list.txt to set it up first." && exit 1
fi
if [ ! -f apps/${app_runtime}/${app_name}.tf ]; then
  cp templates/application.tf.tpl apps/${app_runtime}/${app_name}.tf
  cd apps/${app_runtime}
  sed -i "s/YOUR_APPLICATION_NAME/${app_name}/g" ${app_name}.tf
  sed -i "s/YOUR_APPLICATION_RUNTIME/${app_runtime}/g" ${app_name}.tf
  sed -i "s/YOUR_APP_PROJECT_NAME/${app_name}-project/g" ${app_name}.tf
  sed -i "s/YOUR_APP_PROJECT/${app_name}-tf-project/g" ${app_name}.tf
  sed -i "s/YOUR_SEED_PROJECT_ID/${seed_project_id}/g" ${app_name}.tf
  sed -i "s/YOUR_SA_TO_IMPERSONATE/${sa_to_impersonate}/g" ${app_name}.tf
  sed -i "s/YOUR_INFRA_PROJECT_ID/${infra_project_id}/g" ${app_name}.tf
  sed -i "s/GITHUB_ORG_TO_CLONE_TEMPLATES_FROM/${github_org_to_clone_templates_from}/g" ${app_name}.tf
  sed -i "s/YOUR_TRIGGER_TYPE/${trigger_type}/g" ${app_name}.tf
  sed -i "s/YOUR_GITHUB_TEAM/${github_team}/g" ${app_name}.tf
  sed -i "s/YOUR_REGION/${region}/g" ${app_name}.tf



  if [ -z ${folder_id} ]; then
    sed -i '/YOUR_GCP_FOLDER_ID/d' ${app_name}.tf
  else
    sed -i "s/YOUR_GCP_FOLDER_ID/${folder_id}/g" ${app_name}.tf
  fi

  git add ${app_name}.tf
  git config --global user.name ${user}
  git config --global user.email ${email}
  git config --list
  git commit -m "Cloud Build: Adding new application ${app_name} to the software delivery platform."
  git push origin main

else
  echo "*** Application with name ${app_runtime}/${app_name} already exists. ***"
  exit 0
fi
