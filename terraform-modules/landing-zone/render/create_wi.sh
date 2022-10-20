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

git_org=${1}
git_user=${2}
git_email=${3}
tf_modules_repo=${4}
cluster_name=${5}
cluster_project_id=${6}
env=${7}
index=${8}

sleep_time=20
sleep_index=$((${index}+1))
sleep_total=$((${sleep_time}*${sleep_index}))
sleep $sleep_total
random=$(echo $RANDOM | md5sum | head -c 20; echo)
git clone -b main https://${git_user}:${TF_VAR_github_token}@github.com/${git_org}/${tf_modules_repo} workload-identity-${random}
cd workload-identity-${random}

git checkout main
cd landing-zone
mkdir ${env}
cp render/workload-identity.tpl ./${env}/${cluster_project_id}-${cluster_name}.tf
cp render/variables.tpl ./${env}/variables.tf

find ./${env} -type f -name ${cluster_project_id}-${cluster_name}.tf -exec  sed -i "s/CLUSTER_NAME/${cluster_name}/g" {} +
find ./${env} -type f -name ${cluster_project_id}-${cluster_name}.tf -exec  sed -i "s:CLUSTER_PROJECT:${cluster_project_id}:g" {} +

git add .
git config --global user.name ${git_user}
git config --global user.email ${git_email}
git commit -m "Adding Cloud Deploy target ${cluster_name}."
git push origin

cd ../
rm -rf cloud-deploy-target-${tf_modules_repo}
