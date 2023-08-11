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

set -e
github_user=${1}
github_email=${2}
github_token=${3}
github_org=${4}
acm_repo=${5}
app_name=${6}
gsa=${7}
env=${8}
kubernetes_sa=${9}

random=$(echo $RANDOM | md5sum | head -c 20; echo)
local_acm_repo="${acm_repo}-${random}"
git config --global url."https://${github_user}:${github_token}@github.com".insteadOf "https://github.com"
git clone https://${github_user}:${github_token}@github.com/${github_org}/${acm_repo} ${local_acm_repo}
cd ${local_acm_repo}
if [ ! -d "manifests/apps/${app_name}" ] ; then
  mkdir manifests/apps/${app_name}
  echo "copying the templates"
  cp templates/_namespace-template/namespace.yaml manifests/apps/${app_name}/namespace.yaml
  cp templates/_namespace-template/network-policy.yaml manifests/apps/${app_name}/network-policy.yaml
  cp templates/_namespace-template/serviceaccount.yaml manifests/apps/${app_name}/serviceaccount-${env}.yaml
  cd manifests/apps/${app_name}
  find . -type f -name "*.yaml" -exec  sed -i "s?APP_NAME?${app_name}?g" {} +
  find . -type f -name "*.yaml" -exec  sed -i "s?GOOGLE_SERVICE_ACCOUNT?${gsa}?g" {} +
  find . -type f -name "*.yaml" -exec  sed -i "s?KUBERNETES_SERVICE_ACCOUNT?${kubernetes_sa}?g" {} +
  find . -type f -name "serviceaccount-${env}.yaml" -exec  sed -i "s?ENV?${env}?g" {} +
  git config --global user.name ${github_user}
  git config --global user.email ${github_email}
  git add .
  git commit -m "Creating namespace and Service account for application ${app_name}"
  git push origin
elif [ ! -f "manifests/apps/${app_name}/serviceaccount-${env}.yaml" ] ; then
  cp templates/_namespace-template/serviceaccount.yaml manifests/apps/${app_name}/serviceaccount-${env}.yaml
  cd manifests/apps/${app_name}
  find . -type f -name "serviceaccount-${env}.yaml" -exec  sed -i "s?ENV?${env}?g" {} +
  find . -type f -name "serviceaccount-${env}.yaml" -exec  sed -i "s?APP_NAME?${app_name}?g" {} +
  find . -type f -name "serviceaccount-${env}.yaml" -exec  sed -i "s?GOOGLE_SERVICE_ACCOUNT?${gsa}?g" {} +
  find . -type f -name "serviceaccount-${env}.yaml" -exec  sed -i "s?KUBERNETES_SERVICE_ACCOUNT?${kubernetes_sa}?g" {} +
  git config --global user.name ${github_user}
  git config --global user.email ${github_email}
  git add .
  git commit -m "Creating namespace and Service account for application ${app_name}"
  git push origin
fi
