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
acm_repo_name=${2}
github_user=${3}
github_email=${4}
cluster_env=${5}
cluster_name=${6}

git clone -b dev https://${github_user}:${TF_VAR_github_token}@github.com/${github_org}/${acm_repo_name} ${acm_repo_name}
cd ${acm_repo_name}

git checkout dev
cd manifests/clusters

cp ../../templates/_cluster-template/cluster.yaml ./${cluster_name}-cluster.yaml
cp ../../templates/_cluster-template/selector.yaml ./${cluster_env}-selector.yaml
cp ../../templates/_cluster-template/config-selector.yaml ./config-selector.yaml

find . -type f -name ${cluster_name}-cluster.yaml -exec  sed -i "s/CLUSTER_NAME/${cluster_name}/g" {} +
find . -type f -name ${cluster_name}-cluster.yaml -exec  sed -i "s/ENV/${cluster_env}/g" {} +
find . -type f -name ${cluster_env}-selector.yaml -exec  sed -i "s/ENV/${cluster_env}/g" {} +
find . -type f -name config-selector.yaml -exec  sed -i "s/CLUSTER_NAME/${cluster_name}/g" {} +

git add .
git config --global user.name ${github_user}
git config --global user.email ${github_email}
git commit -m "Adding ${cluster_name} cluster to the ${cluster_env} environment."
git push origin

cd ..
rm -rf ${acm_repo_name}