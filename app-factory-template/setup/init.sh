#!/bin/bash

# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the Licencatcatcat
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

github_url=${1}
user=${2}
email="${user}@github.com"
repo=${3}
cd ${repo}
base_dir="config/repositories-runtime-config"
for app in `cat ${base_dir}/app_runtimes_list.txt`
    do
      if [ -z `find apps -maxdepth 1 -type d -name ${app}` ]; then
        echo "${app} is specified in app_runtimes_list.txt but corresponding folder was not found. Creating apps/${app}"
        mkdir apps/${app} || exit 1
        cp templates/variables.tf.tpl apps/${app}/variables.tf || exit 1
        if [ $(grep "module \"${app}\"" apps/main.tf| wc -l) -eq 0 ]; then
          cat << EOF >> apps/main.tf
module "${app}" {
    source = "./${app}"
}
EOF
        fi
        git config --global user.name ${user}
        git config --global user.email ${email}
        git add apps/${app}/variables.tf apps/main.tf #apps/${app}/provider.tf
        git commit -m "Cloud Build: Adding new folder for runtime ${app}."
        git push origin main
      fi
    done