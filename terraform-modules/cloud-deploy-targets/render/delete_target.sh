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
tf_modules_repo=${2}
github_user=${3}
github_email=${4}
cluster_name=${5}

git clone -b main https://${github_user}:${TF_VAR_github_token}@github.com/${github_org}/${tf_modules_repo} cloud-deploy-target-${tf_modules_repo}
cd cloud-deploy-target-${tf_modules_repo}

git checkout main
cd cloud-deploy-targets

rm ./${cluster_name}.tf

git add .
git config --global user.name ${github_user}
git config --global user.email ${github_email}
git commit -m "Deleting Cloud Deploy target ${cluster_name}."
git push origin

cd ../
rm -rf cloud-deploy-target-${tf_modules_repo}
