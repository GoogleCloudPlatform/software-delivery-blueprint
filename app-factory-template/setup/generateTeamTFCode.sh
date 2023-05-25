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

user=${1}
email="${user}@github.com"
org=${2}
raw_team_name=${3}
repo=${4}
teams_basedir="teams"
configdir="config/teams-configs"
teams_module="git::https://github.com/${org}/terraform-modules.git//manage-teams"

cd ${repo}
target_dir="teams"  #This is where all teams related tf files will be created
team_name=$(echo ${raw_team_name} | tr '[:upper:]' '[:lower:]') #converting team name to lowercase as we will use that to name directories. Team names are case in-sensitive in github anyway

if [ $(find ${teams_basedir} -type d -name ${team_name} | wc -l) -gt 0 ]; then
  echo "A folder with the name ${team_name} already exists under teams dir in the repo. Adding another team with the same name will result in error. Exiting." && exit 1
fi

if [ ! -f ${configdir}/${team_name}.tpl ]; then #If there is no config file created for the team, it will be created with all defaults as in section below
  echo "Membership and repo permissions template missing under config/tams-configs for this team"
  parent_team_id="null"
  privacy="closed"
  members="[]"
  maintainers="[]"
  admin_repos="[]"
  maintain_repos="[]"
  push_repos="[]"
  triage_repos="[]"
  pull_repos="[]"
else
  #if config file for the team is present, read and parse the values and assign them to variables
  team_description=$(grep '^team_description' ${configdir}/${team_name}.tpl | awk -F '=' '{print $2}')
  parent_team=$(grep '^parent_team' ${configdir}/${team_name}.tpl | awk -F '=' '{print $2}')
  members=$(grep '^members' ${configdir}/${team_name}.tpl | awk -F '=' '{print $2}')
  maintainers=$(grep '^maintainers' ${configdir}/${team_name}.tpl | awk -F '=' '{print $2}')
  privacy=$(grep '^privacy' ${configdir}/${team_name}.tpl | awk -F '=' '{print $2}')
  admin_repos=$(grep '^admin_repositories' ${configdir}/${team_name}.tpl | awk -F '=' '{print $2}')
  maintain_repos=$(grep '^maintain_repositories' ${configdir}/${team_name}.tpl | awk -F '=' '{print $2}')
  push_repos=$(grep '^push_repositories' ${configdir}/${team_name}.tpl | awk -F '=' '{print $2}')
  triage_repos=$(grep '^triage_repositories' ${configdir}/${team_name}.tpl | awk -F '=' '{print $2}')
  pull_repos=$(grep '^pull_repositories' ${configdir}/${team_name}.tpl | awk -F '=' '{print $2}')
fi

#If parent team is not null, we need to traverse to the parent teams folder under team and create child team's tf folder there
parent_team=${parent_team:-null}
if [ ${parent_team} != "null" ]; then
  if [ $(find ${teams_basedir} -type d -iname ${parent_team} | wc -l) -gt 0 ]; then
    target_dir=$(find ${teams_basedir} -type d -iname ${parent_team})
  else
    echo "parent team folder ${parent_team} doesnt exist under teams folder. Maybe, it was not created using td. Please import the team to tf state" && exit 1
  fi
fi

#Make a new folder for the new team once we have found the parent folder it should be created in
mkdir ${target_dir}/${team_name} || exit 1
cp templates/team.tf.tpl ${target_dir}/${team_name}/${team_name}.tf
cp templates/outputs.tf.tpl ${target_dir}/${team_name}/outputs.tf

#source field in Terraform module can not take variables. It takes path to the module so we construct the path to teams tf module
module_loc=`echo ${target_dir}/${team_name} | sed "s/^teams/./"`

#If parent team is not null, we need to figure its id so it can be passed while creating child team. Parent team's id can be retrieved from the output variable of the module that created it.
if [ ${parent_team} != "null" ]; then
  #Following is a pattern replacement to construct tf statement that passed the id from parent team's tf module into a variable
  parent_team_id_module="module.team_$(echo ${parent_team} | tr '[:upper:]' '[:lower:]').id"
else
  #If parent team is null, we simply pass it as null while creating child team
  parent_team_id_module="null"
fi

#If the module is already called in main.tf, don't duplicate it
if [ $(grep "module \"team_$team_name\" {" teams/main.tf | wc -l) -eq 0 ]; then
  cat <<EOF >>teams/main.tf

  module "team_${team_name}" {
    source = "${module_loc}"
    parent_team_id = ${parent_team_id_module}
  }
EOF
fi
#Stage the file now as we will change directories and there will be extra line of code to keep track of this dir and stage this file from somewhere else
git add teams/main.tf
#Now change the dir and move to the location where we will create the tf files for the new team
cd ${target_dir}/${team_name} || exit 1


#Prep the tf file by replacing placeholder strings with values/variables
sed -i "s/PARENT_TEAM_ID/var\.parent_team_id/g" ${team_name}.tf
sed -i "s!PATH_TO_MODULE!${teams_module}!g" ${team_name}.tf
sed -i "s/YOUR_TEAM_NAME/${raw_team_name}/g" ${team_name}.tf
sed -i "s/YOUR_TEAM_DESCRIPTION/${team_description:-""}/g" ${team_name}.tf
sed -i "s/YOUR_TEAM_PRIVACY/${privacy:-closed}/g" ${team_name}.tf
sed -i "s/YOUR_TEAM_MEMBERS/${members:-"[]"}/g" ${team_name}.tf
sed -i "s/YOUR_TEAM_MAINTAINERS/${maintainers:-"[]"}/g" ${team_name}.tf
sed -i "s/ADMIN_REPOSITORIES/${admin_repos:-"[]"}/g" ${team_name}.tf
sed -i "s/MAINTAIN_REPOSITORIES/${maintain_repos:-"[]"}/g" ${team_name}.tf
sed -i "s/PUSH_REPOSITORIES/${push_repos:-"[]"}/g" ${team_name}.tf
sed -i "s/TRIAGE_REPOSITORIES/${triage_repos:-"[]"}/g" ${team_name}.tf
sed -i "s/PULL_REPOSITORIES/${pull_repos:-"[]"}/g" ${team_name}.tf
sed -i "s/YOUR_MODULE/${raw_team_name}/g" outputs.tf

#Stage and commit the files and.....push
git add ${team_name}.tf outputs.tf
git config --global user.name ${user}
git config --global user.email ${email}
git commit -m "Cloud Build: Adding new team ${raw_team_name} to the software delivery platform."
git push origin main


