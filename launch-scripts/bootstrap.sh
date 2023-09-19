#!/usr/bin/env bash
shopt -s expand_aliases

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

# Verify that the scripts are being run from Linux and not Mac
if [[ $OSTYPE != "linux-gnu" ]]; then
    echo "ERROR: This script and consecutive set up scripts have only been tested on Linux. Currently, only Linux (debian) is supported. Please run in Cloud Shell or in a VM running Linux".
    exit;
fi

export SCRIPT_DIR=$(dirname $(readlink -f $0 2>/dev/null) 2>/dev/null || echo "${PWD}/$(dirname $0)")
START_DIR=${PWD}
BASE_DIR="${SCRIPT_DIR}/../"
LOG_DIR="${SCRIPT_DIR}/../../logs/infra"
mkdir -p ${LOG_DIR}
TEMP_DIR="${BASE_DIR}/../temp"
mkdir -p ${TEMP_DIR}

if [ ! -f ${LOG_DIR}/vars.sh ]; then
    cp ${SCRIPT_DIR}/vars.sh ${LOG_DIR}/vars.sh
    source ${LOG_DIR}/vars.sh
else
    source ${LOG_DIR}/vars.sh
fi

export LOG_FILE=${LOG_DIR}/platform-bootstrap-$(date +%s).log
touch ${LOG_FILE}
exec 2>&1
exec &> >(tee -i ${LOG_FILE})

#functions.sh helps make the script interactive
source ${SCRIPT_DIR}/functions.sh

# Ensure Org ID is defined otherwise collect
while [ -z ${ORG_NAME} ]
    do
    read -p "$(echo -e "Please provide your Organization Name (your active account must be Org Admin): ")" ORG_NAME
    done

# Validate ORG_NAME exists
ORG_ID=$(gcloud organizations list \
  --filter="display_name=${ORG_NAME}" \
  --format="value(ID)")
[ ${ORG_ID} ] || { echo "Organization with that name does not exist or you do not have correct permissions in this org."; exit; }

# Ensure Billing account is defined otherwise collect
while [ -z ${BILLING_ACCOUNT_ID} ]
    do
    read -p "$(echo -e "Please provide your Billing Account ID (your active account must be Billing Account Admin): ")" BILLING_ACCOUNT_ID
    done

# Check if FOLDER_NAME is needed. If not, enter just press enter
if [ -z ${FOLDER_NAME} ];then
    read -p "$(echo -e "Please provide Folder Name (your active account must be Org Admin): ")" FOLDER_NAME
fi

# Ensure infra setup project name is defined
while [ -z ${INFRA_SETUP_PROJECT} ]
    do
    read -p "$(echo -e "Please provide the name for multi-tenant admin project: ")" INFRA_SETUP_PROJECT
    done

# Ensure infra setup repo name is defined
while [ -z ${INFRA_SETUP_REPO} ]
    do
    read -p "$(echo -e "Please provide the name for multi-tenant platform repo: ")" INFRA_SETUP_REPO
    done

# Ensure app setup project name is defined
while [ -z ${APP_SETUP_PROJECT} ]
    do
    read -p "$(echo -e "Please provide the name for App project factory: ")" APP_SETUP_PROJECT
    done

# Ensure app setup repo name is defined
while [ -z ${APP_SETUP_REPO} ]
    do
    read -p "$(echo -e "Please provide the name for App factory repo: ")" APP_SETUP_REPO
    done

# Ensure github user is defined
while [ -z ${GITHUB_USER} ]
    do
    read -p "$(echo -e "Please provide your github user: ")" GITHUB_USER
    done

# Ensure github personal access token is defined
while [ -z ${TOKEN} ]
    do
    read -p "$(echo -e "Please provide your github personal access token: ")" TOKEN
    done

# Ensure github org is defined
while [ -z ${GITHUB_ORG} ]
    do
    read -p "$(echo -e "Please provide your github org: ")" GITHUB_ORG
    done

# Ensure REGION is defined
while [ -z ${REGION} ]
    do
    read -p "$(echo -e "Please provide the region where resources will be created: ")" REGION
    done

while [ -z ${SEC_REGION} ]
    do
    read -p "$(echo -e "Please provide the secondary region for GKE multi cluster in prod: ")" SEC_REGION
    done

# Let the user chose the kind of trigger they want to create in Application factory
while [ -z ${TRIGGER_TYPE} ]
    do
    read -p "$(echo -e "Enter \"webhook\" for creating webhook triggers or \"github\" for github trigger: ")" TRIGGER_TYPE
    done

# Ensure app setup project name is defined
while [ -z ${APP_SETUP_PROJECT} ]
    do
    read -p "$(echo -e "Please provide the name for App project factory: ")" APP_SETUP_PROJECT
    done

# Ensure app setup repo name is defined
while [ -z ${APP_SETUP_REPO} ]
    do
    read -p "$(echo -e "Please provide the name for App factory repo: ")" APP_SETUP_REPO
    done

#Set python3 path
export PYTHON=$(which python3)
if [ -z ${PYTHON} ]; then
  echo "ERROR: `which python3` did not yield any path to the executable. Please install python3 if not done already and make sure to add the directory of the executable in PATH environment variable"
  exit;
fi
TEMPLATE_INFRA_REPO="platform-template"
TEMPLATE_COMMON_SETUP="common-setup"
TEMPLATE_ACM_REPO="acm-template"
ACM_REPO="acm-${INFRA_SETUP_REPO}"
TF_MODULES="terraform-modules"
TIMESTAMP=$(date "+%Y%m%d%H%M%S")
SA_FOR_API_KEY="api-key-sa-${TIMESTAMP}"
PROJECT_ID_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1)
TEMPLATE_APP_REPO="app-factory-template"
GITHUB_SECRET_NAME="github-token-app"
TEAM_TRIGGER_NAME="add-team-files"
APP_TRIGGER_NAME="create-app"
PLAN_TRIGGER_NAME="tf-plan"
APPLY_TRIGGER_NAME="tf-apply"
INFRA_TRIGGER_NAME="create-infra"
COMMON_TRIGGER_NAME="common-setup-trigger"
APP_TEMPLATES=$(ls ${BASE_DIR} | grep  -- "app-template-")
APP_INFRA_TEMPLATE="infra-template"
TIMESTAMP=$(date "+%Y%m%d%H%M%S")
SECRET_PROJECT="secret-common"
CUSTOM_SA_BILLING="billing-assign"
CUSTOM_SA_PROJECT="project-creator-assign"

title_no_wait "#######################################################"
title_no_wait "             Bootstrapping platform                    "
title_no_wait "#######################################################"
if [[ -z ${INFRA_SETUP_PROJECT_ID} ]]; then
    INFRA_SETUP_PROJECT_ID=${INFRA_SETUP_PROJECT}-${PROJECT_ID_SUFFIX}
fi

if [[ -z ${SECRET_PROJECT_ID} ]]; then
    SECRET_PROJECT_ID=${SECRET_PROJECT}-${PROJECT_ID_SUFFIX}
fi

if [[ -z ${APP_SETUP_PROJECT_ID} ]]; then
    APP_SETUP_PROJECT_ID=${APP_SETUP_PROJECT}-${PROJECT_ID_SUFFIX}
fi

#Storing variables in the state file so the script start from where it left off in even of a failure
grep -q "export INFRA_SETUP_PROJECT_ID.*" ${LOG_DIR}/vars.sh || echo -e "export INFRA_SETUP_PROJECT_ID=${INFRA_SETUP_PROJECT_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export INFRA_SETUP_PROJECT=.*" ${LOG_DIR}/vars.sh || echo -e "export INFRA_SETUP_PROJECT=${INFRA_SETUP_PROJECT}" >> ${LOG_DIR}/vars.sh
grep -q "export BILLING_ACCOUNT_ID=.*" ${LOG_DIR}/vars.sh|| echo -e "export BILLING_ACCOUNT_ID=${BILLING_ACCOUNT_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export ORG_NAME=.*" ${LOG_DIR}/vars.sh|| echo -e "export ORG_NAME=${ORG_NAME}" >> ${LOG_DIR}/vars.sh
grep -q "export ORG_ID=.*" ${LOG_DIR}/vars.sh || echo -e "export ORG_ID=${ORG_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export FOLDER_NAME=.*" ${LOG_DIR}/vars.sh|| echo -e "export FOLDER_NAME=${FOLDER_NAME}" >> ${LOG_DIR}/vars.sh
grep -q "export FOLDER_ID=.*" ${LOG_DIR}/vars.sh || echo -e "export FOLDER_ID=${FOLDER_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export INFRA_SETUP_REPO=.*" ${LOG_DIR}/vars.sh || echo -e "export INFRA_SETUP_REPO=${INFRA_SETUP_REPO}" >> ${LOG_DIR}/vars.sh
grep -q "export TEMPLATE_COMMON_SETUP=.*" ${LOG_DIR}/vars.sh || echo -e "export TEMPLATE_COMMON_SETUP=${TEMPLATE_COMMON_SETUP}" >> ${LOG_DIR}/vars.sh
grep -q "export GITHUB_USER=.*" ${LOG_DIR}/vars.sh || echo -e "export GITHUB_USER=${GITHUB_USER}" >> ${LOG_DIR}/vars.sh
grep -q "export TOKEN=.*" ${LOG_DIR}/vars.sh|| echo -e "export TOKEN=${TOKEN}" >> ${LOG_DIR}/vars.sh
grep -q "export GITHUB_ORG=.*" ${LOG_DIR}/vars.sh || echo -e "export GITHUB_ORG=${GITHUB_ORG}" >> ${LOG_DIR}/vars.sh
grep -q "export REGION=.*" ${LOG_DIR}/vars.sh || echo -e "export REGION=${REGION}" >> ${LOG_DIR}/vars.sh
grep -q "export SEC_REGION=.*" ${LOG_DIR}/vars.sh || echo -e "export SEC_REGION=${SEC_REGION}" >> ${LOG_DIR}/vars.sh
grep -q "export SECRET_PROJECT_ID=.*" ${LOG_DIR}/vars.sh || echo -e "export SECRET_PROJECT_ID=${SECRET_PROJECT_ID}" >> ${LOG_DIR}/vars.sh

if [[ "${TRIGGER_TYPE,,}" == "webhook" ]] || [[ "${TRIGGER_TYPE,,}" == "github" ]]; then
    grep -q "export TRIGGER_TYPE=.*" ${LOG_DIR}/vars.sh || echo -e "export TRIGGER_TYPE=${TRIGGER_TYPE}" >> ${LOG_DIR}/vars.sh
else
   title_no_wait "The trigger type ${TRIGGER_TYPE} is invalid. Specify webhook or github"
   exit 1
fi


#FUNCTIONS DEFINITIONS BELOW
generate_api_key () {
    title_no_wait "Creating a Service Account for creating an API key ..."
    print_and_execute "gcloud iam service-accounts create ${SA_FOR_API_KEY}  --display-name \"API Key ${SA_FOR_API_KEY}\""

    title_no_wait "Granting access to cloudbuild SA for accessing the API key ..."
    print_and_execute "gcloud projects add-iam-policy-binding ${1} \
                       --member serviceAccount:${SA_FOR_API_KEY}@${1}.iam.gserviceaccount.com \
                       --role roles/serviceusage.apiKeysAdmin"

    title_no_wait "Creating credentials for the SA ..."
    print_and_execute "gcloud iam service-accounts keys create ~/credentials.json \
                       --iam-account ${SA_FOR_API_KEY}@${1}.iam.gserviceaccount.com"

    if [[ `which oauth2l | wc -l` -eq 0 ]]; then
        title_no_wait "oauth2l not installed"
        title_no_wait "Download and install oauth2l ..."
        print_and_execute "git clone  https://${GITHUB_USER}:${TOKEN}@github.com/google/oauth2l ${START_DIR}/oauth2l-${TIMESTAMP}"
        print_and_execute "cd ${START_DIR}/oauth2l-${TIMESTAMP}"
        print_and_execute "make dev"
        print_and_execute "oauth2l fetch --credentials ~/credentials.json --scope cloud-platform"
        print_and_execute "alias gcurl='curl -S -H \"$(oauth2l header --json ~/credentials.json cloud-platform userinfo.email)\" -H \"Content-Type: application/json\"'"

    else
        title_no_wait "oauth2l is already installed ..."
        print_and_execute "oauth2l fetch --credentials ~/credentials.json --scope cloud-platform"
        print_and_execute "alias gcurl='curl -S -H \"$(oauth2l header --json ~/credentials.json cloud-platform userinfo.email)\" -H \"Content-Type: application/json\"'"
    fi

    title_no_wait "checking if we are all set to create API key ..."
    print_and_execute "type gcurl"
    if [ $? -ne 0 ]; then
        title_no_wait "gcurl alias not set. Problem in using oauth2l. Exiting"
        exit 1
    fi

    title_no_wait "Creating a API key for webhook ..."
    print_and_execute "operation_id=$(gcurl https://apikeys.googleapis.com/v2/projects/${2}/locations/global/keys -X POST -d '{"displayName" : "webhook","restrictions": {"api_targets": [{"service": "cloudbuild.googleapis.com"}]}}' | jq .name)"
    title_no_wait "Polling for the operation to complete ..."
    status="false"
    while  [ ${status} != "true" ]
    do
        title_no_wait "Waiting for operation to create API to complete. Sleeping for 5"
        print_and_execute "echo ${operation_id}"
        print_and_execute "status=$(gcurl https://apikeys.googleapis.com/v2/${operation_id} | jq .done)"
        if [[ -z ${status} ]]; then
            title_no_wait "Unable to fetch the status of API key create operation. Possibly the command to create API key had issues. Aborting"
            exit
        fi
        sleep 5
    done
    print_and_execute "API_KEY=$(gcurl https://apikeys.googleapis.com/v2/${operation_id} | jq .response.keyString)"
}

create_webhook () {
    trigger=$1
    project_id=$2
    project_number=$3
    repo=$4
    echo "Trigger is $trigger"
    title_no_wait "Creating a secret for webhook ..."
    SECRET_NAME=webhook-secret-${trigger}
    SECRET_VALUE=$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 15))
    SECRET_PATH=projects/${project_number}/secrets/${SECRET_NAME}/versions/1
    print_and_execute "printf ${SECRET_VALUE} | gcloud secrets create ${SECRET_NAME} --data-file=-"
    title_no_wait "Providing read access to Cloudbuild service account on the secret ..."
    print_and_execute "gcloud secrets add-iam-policy-binding ${SECRET_NAME} \
         --member=serviceAccount:service-${project_number}@gcp-sa-cloudbuild.iam.gserviceaccount.com \
         --role='roles/secretmanager.secretAccessor'"

    title_no_wait "Creating a webhook trigger ..."
    if [ "${trigger}" = "${TEAM_TRIGGER_NAME}" ]; then
        print_and_execute "gcloud alpha builds triggers create webhook --name=\"${TEAM_TRIGGER_NAME}\"  --inline-config=\"${TEMP_DIR}/${repo}/add-team-tf-files-webhook.yaml\" --secret=${SECRET_PATH} --substitutions='_REPO_NAME=${repo},_TEAM_NAME=\$(body.message.team)'"
    elif [ "${trigger}" = "${APP_TRIGGER_NAME}" ]; then
        print_and_execute "gcloud alpha builds triggers create webhook --name=\"${APP_TRIGGER_NAME}\"  --inline-config=\"${TEMP_DIR}/${repo}/add-app-tf-files-webhook.yaml\" --secret=${SECRET_PATH} --substitutions='_REPO_NAME=${repo},_APP_NAME=\$(body.message.app),_APP_RUNTIME=\$(body.message.runtime),_INFRA_PROJECT_ID=${project_id},_REGION=${REGION},_TRIGGER_TYPE=\$(body.message.trigger_type),_GITHUB_TEAM=\$(body.message.github_team),_FOLDER_ID=${FOLDER_ID}'"
    elif [ "${trigger}" = "${PLAN_TRIGGER_NAME}" ]; then
        print_and_execute "gcloud alpha builds triggers create webhook --name=\"${PLAN_TRIGGER_NAME}\"  --inline-config=\"${TEMP_DIR}/${repo}/tf-plan-webhook.yaml\" --secret=${SECRET_PATH} --substitutions='_REPO_NAME=${repo}'"
    elif [ "${trigger}" = "${APPLY_TRIGGER_NAME}" ]; then
        print_and_execute "gcloud alpha builds triggers create webhook --name=\"${APPLY_TRIGGER_NAME}\"  --inline-config=\"${TEMP_DIR}/${repo}/tf-apply-webhook.yaml\" --secret=${SECRET_PATH} --substitutions='_REPO_NAME=${repo}'"
    elif [ "${trigger}" = "${INFRA_TRIGGER_NAME}" ]; then
        print_and_execute "gcloud alpha builds triggers create webhook --name=\"${INFRA_TRIGGER_NAME}\"  --inline-config=\"${TEMP_DIR}/${repo}/cloudbuild-webhook.yaml\" --secret=${SECRET_PATH} --substitutions='_REF=\$(body.ref),_REPO=\$(body.repository.full_name),_COMMIT_MSG=\$(body.head_commit.message)'  --subscription-filter='(!_COMMIT_MSG.matches(\"IGNORE\"))'"
    elif [ "${trigger}" = "${COMMON_TRIGGER_NAME}" ]; then
        print_and_execute "gcloud alpha builds triggers create webhook --name=\"${COMMON_TRIGGER_NAME}\"  --inline-config=\"${TEMP_DIR}/${repo}/cloudbuild-webhook.yaml\" --secret=${SECRET_PATH} --substitutions='_REF=\$(body.ref),_REPO=\$(body.repository.full_name),_COMMIT_MSG=\$(body.head_commit.message)'  --subscription-filter='(!_COMMIT_MSG.matches(\"IGNORE\"))'"
    else
        title_no_wait "Invalid trigger name passed"
        print_and_execute "exit 1"
    fi
    ## Retrieve the URL
    if [ "${trigger}" = "${INFRA_TRIGGER_NAME}" ] || [ "${trigger}" = "${COMMON_TRIGGER_NAME}" ]; then
        WEBHOOK_URL="https://cloudbuild.googleapis.com/v1/projects/${project_id}/triggers/${trigger}:webhook?key=${API_KEY}&secret=${SECRET_VALUE}"

        title_no_wait "Creating a github trigger ..."

        print_and_execute "curl -H \"Authorization: token ${TOKEN}\" \
         -d '{\"config\": {\"url\": \"${WEBHOOK_URL}\", \"content_type\": \"json\"},\"active\": true,\"events\": [\"push\"]}' \
         -X POST https://api.github.com/repos/$GITHUB_ORG/${repo}/hooks"
    fi

}
title_no_wait "STARTING"
# Create folder if the FOLDER_NAME was not entered blank
if [[ -n ${FOLDER_NAME} ]]; then
    title_no_wait "Checking if folder ${FOLDER_NAME} already exists..."
    print_and_execute "folder_flag=$(gcloud resource-manager folders list --organization ${ORG_ID} --format=json --filter="display_name=${FOLDER_NAME}" | grep "\"displayName\": \"$FOLDER_NAME\"" | wc -l)"
    if [ ${folder_flag} -eq 0 ]; then
        title_no_wait "Folder ${FOLDER_NAME} does not exist. Creating it..."
        print_and_execute "gcloud resource-manager folders create --display-name=${FOLDER_NAME} --organization=${ORG_ID}"
        FOLDER_ID=$(gcloud resource-manager folders list --organization=${ORG_ID} --filter="display_name=${FOLDER_NAME}" --format="value(ID)")
        grep -q "export FOLDER_ID.*" ${LOG_DIR}/vars.sh || echo -e "export FOLDER_ID=${FOLDER_ID}" >> ${LOG_DIR}/vars.sh
    else
        title_no_wait "Folder ${FOLDER_NAME} already exists. Finding its ID..."
        FOLDER_ID=$(gcloud resource-manager folders list --organization=${ORG_ID} --filter="display_name=${FOLDER_NAME}" --format="value(ID)")
        grep -q "export FOLDER_ID.*" ${LOG_DIR}/vars.sh || echo -e "export FOLDER_ID=${FOLDER_ID}" >> ${LOG_DIR}/vars.sh
    fi
fi

# Create platform admin project
title_no_wait "Checking if ${INFRA_SETUP_PROJECT_ID} exist already..."
project_id=$(gcloud  projects list  --filter="PROJECT_ID=${INFRA_SETUP_PROJECT_ID}" --format="value(PROJECT_ID)")
if [[ -z ${project_id} ]]; then
    title_no_wait "${INFRA_SETUP_PROJECT_ID} does not exist.Creating platform setup project ..."
    if [[ -n ${FOLDER_NAME} ]]; then
        print_and_execute "gcloud projects create ${INFRA_SETUP_PROJECT_ID} \
            --folder ${FOLDER_ID} \
            --name ${INFRA_SETUP_PROJECT_ID} \
            --set-as-default"
    else
        print_and_execute "gcloud projects create ${INFRA_SETUP_PROJECT_ID} \
        --name ${INFRA_SETUP_PROJECT_ID} \
        --set-as-default"
    fi
else
    title_no_wait "${INFRA_SETUP_PROJECT_ID} already exists, not creating it..."
fi

title_no_wait "STARTING"
title_no_wait "Adding git configs"
print_and_execute "git config --global user.email ${GITHUB_USER}@github.com"
print_and_execute "git config --global user.name ${GITHUB_USER}"
title_no_wait "Linking billing account to the ${INFRA_SETUP_PROJECT_ID}..."
print_and_execute "gcloud beta billing projects link ${INFRA_SETUP_PROJECT_ID} \
--billing-account ${BILLING_ACCOUNT_ID}"

# Creating terraform modules repo in your org and committing the code from template to it
title_no_wait "Checking if ${TF_MODULES} already exists..."
repo_id_exists=$(curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/json" "https://api.github.com/repos/${GITHUB_ORG}/${TF_MODULES}" | jq '.id')
if [ ${repo_id_exists} = "null" ]; then
    title_no_wait "${TF_MODULES} does not exist. Creating it..."
    print_and_execute "repo_id=$(curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/json" \
        -d "{ \
            \"name\": \"${TF_MODULES}\", \
            \"private\": true \
        }" \
    -X POST https://api.github.com/orgs/${GITHUB_ORG}/repos | jq '.id')"

    sleep 5
    if [ ${repo_id} = "null" ]; then
        echo "Unable to create git repo.Exiting"
        exit 1
    else
        grep -q "export TF_MODULES=.*" ${LOG_DIR}/vars.sh || echo -e "export TF_MODULES=${TF_MODULES}" >> ${LOG_DIR}/vars.sh
    fi
else
    echo "The repo ${TF_MODULES} already exists, not creating it"
fi
title_no_wait "Cloning recently created terraform-modules repo..."
print_and_execute "rm -rf ${TEMP_DIR}/${TF_MODULES} && git clone  https://${GITHUB_USER}:${TOKEN}@github.com/${GITHUB_ORG}/${TF_MODULES} ${TEMP_DIR}/${TF_MODULES}"
if [[ -d ${BASE_DIR}/${TEMPLATE_TF_MODULES} ]]; then
    print_and_execute "cd ${TEMP_DIR}/${TF_MODULES}"
    print_and_execute "git checkout main 2>/dev/null || git checkout -b main"
    print_and_execute "cp -r ${BASE_DIR}/${TF_MODULES}/* ."
    print_and_execute "find cloud-functions/src -type f -exec  sed -i \"s/YOUR_SECRET_PROJECT_ID/${SECRET_PROJECT_ID}/g\" {} +"
    print_and_execute "find cloud-functions/src -type f -exec  sed -i \"s/YOUR_GCP_ORG_ID/${ORG_ID}/g\" {} +"
    print_and_execute "git add . && git commit -m \"Adding repo\""
    print_and_execute "git push -u origin main"
else
    title_no_wait "Can not find ${BASE_DIR}/${TF_MODULES}. Exiting"
    print_and_execute "exit 1"
fi

# Creating acm repo in your org and committing the code from template to it
title_no_wait "Checking if ${ACM_REPO} already exists..."
repo_id_exists=$(curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/json" "https://api.github.com/repos/${GITHUB_ORG}/${ACM_REPO}" | jq '.id')
if [ ${repo_id_exists} = "null" ]; then
    title_no_wait "${ACM_REPO} does not exist. Creating it..."
    print_and_execute "repo_id=$(curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/json" \
        -d "{ \
            \"name\": \"${ACM_REPO}\", \
            \"private\": true \
        }" \
    -X POST https://api.github.com/orgs/${GITHUB_ORG}/repos | jq '.id')"

    sleep 5
    if [ ${repo_id} = "null" ]; then
        echo "Unable to create git repo.Exiting"
        exit 1
    else
        grep -q "export ACM_REPO=.*" ${LOG_DIR}/vars.sh || echo -e "export ACM_REPO=${ACM_REPO}" >> ${LOG_DIR}/vars.sh
    fi
else
    echo "The repo ${ACM_REPO} already exists, not creating it"
fi
title_no_wait "Cloning recently created acm repo..."
print_and_execute "rm -rf ${TEMP_DIR}/${ACM_REPO} && git clone  https://${GITHUB_USER}:${TOKEN}@github.com/${GITHUB_ORG}/${ACM_REPO} ${TEMP_DIR}/${ACM_REPO}"
if [[ -d ${BASE_DIR}/${TEMPLATE_ACM_REPO} ]]; then
    print_and_execute "cd ${TEMP_DIR}/${ACM_REPO}"
    print_and_execute "git checkout dev 2>/dev/null || git checkout -b dev"
    print_and_execute "cp -r ${BASE_DIR}/${TEMPLATE_ACM_REPO}/* ."
    print_and_execute "git add . && git commit -m \"Adding repo\""
    print_and_execute "git push -u origin dev"

    title_no_wait "Pushing staging branch to ${ACM_REPO} ..."
    print_and_execute "git checkout staging 2>/dev/null || git checkout -b staging"
    print_and_execute "git push -u origin staging"

    title_no_wait "Pushing prod branch to ${ACM_REPO} ..."
    print_and_execute "git checkout prod 2>/dev/null || git checkout -b prod"
    print_and_execute "git push -u origin prod"
else
    title_no_wait "Can not find ${BASE_DIR}/${TEMPLATE_ACM_REPO}. Exiting"
    print_and_execute "exit 1"
fi

#Secure staging and prod branch but disallowing direct push to them
title_no_wait "Applying branch protection..."
print_and_execute "curl -s -X PUT -u $GITHUB_USER:$TOKEN -H \"Accept: application/vnd.github.v3+json\" \
https://api.github.com/repos/$GITHUB_ORG/$ACM_REPO/branches/staging/protection \
 -d \"{ \
      \\\"restrictions\\\": null,\\\"required_status_checks\\\": null, \
      \\\"required_pull_request_reviews\\\" : {\\\"dismissal_restrictions\\\": {}, \
      \\\"dismiss_stale_reviews\\\": false,\\\"require_code_owner_reviews\\\": true,\
      \\\"required_approving_review_count\\\": 1,\\\"bypass_pull_request_allowances\\\": {}}, \
      \\\"enforce_admins\\\": true
      }\" \
      "

print_and_execute "curl -s -X PUT -u $GITHUB_USER:$TOKEN -H \"Accept: application/vnd.github.v3+json\" \
https://api.github.com/repos/$GITHUB_ORG/$ACM_REPO/branches/prod/protection \
 -d \"{ \
      \\\"restrictions\\\": null,\\\"required_status_checks\\\": null, \
      \\\"required_pull_request_reviews\\\" : {\\\"dismissal_restrictions\\\": {}, \
      \\\"dismiss_stale_reviews\\\": false,\\\"require_code_owner_reviews\\\": true,\
      \\\"required_approving_review_count\\\": 1,\\\"bypass_pull_request_allowances\\\": {}}, \
      \\\"enforce_admins\\\": true
      }\" \
      "

# Creating platform IaC repo in your org and committing the code from template to it
title_no_wait "Checking if ${INFRA_SETUP_REPO} already exists..."
repo_id_exists=$(curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/json" "https://api.github.com/repos/${GITHUB_ORG}/${INFRA_SETUP_REPO}" | jq '.id')
if [ ${repo_id_exists} = "null" ]; then
    title_no_wait "${INFRA_SETUP_REPO} does not exist. Creating it ..."
    print_and_execute "repo_id=$(curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/json" \
        -d "{ \
            \"name\": \"${INFRA_SETUP_REPO}\", \
            \"private\": true \
        }" \
        -X POST https://api.github.com/orgs/${GITHUB_ORG}/repos | jq '.id')"

    sleep 5
    if [ ${repo_id} = "null" ]; then
        echo "Unable to create git repo.Exiting"
        exit 1
    else
        grep -q "export INFRA_SETUP_REPO=.*" ${LOG_DIR}/vars.sh || echo -e "export INFRA_SETUP_REPO=${INFRA_SETUP_REPO}" >> ${LOG_DIR}/vars.sh
    fi
else
    echo "The repo ${INFRA_SETUP_REPO} already exists, not creating it"
fi

title_no_wait "Cloning recently created infra repo ${INFRA_SETUP_REPO}..."
print_and_execute "rm -rf ${TEMP_DIR}/${INFRA_SETUP_REPO} && git clone  https://${GITHUB_USER}:${TOKEN}@github.com/${GITHUB_ORG}/${INFRA_SETUP_REPO} ${TEMP_DIR}/${INFRA_SETUP_REPO}"
if [[ -d ${BASE_DIR}/${TEMPLATE_INFRA_REPO} ]]; then
    print_and_execute "cd ${TEMP_DIR}/${INFRA_SETUP_REPO}"
    print_and_execute "git checkout dev 2>/dev/null || git checkout -b dev"
    print_and_execute "cp -r ${BASE_DIR}/${TEMPLATE_INFRA_REPO}/* ."
    print_and_execute "git add . && git commit -m \"Adding repo\""
    print_and_execute "git push -u origin dev"

    title_no_wait "Pushing staging branch to ${INFRA_SETUP_REPO} ..."
    print_and_execute "git checkout staging 2>/dev/null || git checkout -b staging"
    print_and_execute "git push -u origin staging"

    title_no_wait "Pushing prod branch to ${INFRA_SETUP_REPO} ..."
    print_and_execute "git checkout prod 2>/dev/null || git checkout -b prod"
    print_and_execute "git push -u origin prod"
else
    title_no_wait "Can not find ${BASE_DIR}/${TEMPLATE_INFRA_REPO}. Exiting"
    print_and_execute "exit 1"
fi

#Secure staging and prod branch but disallowing direct push to them
title_no_wait "Applying branch protection..."
print_and_execute "curl -s -X PUT -u $GITHUB_USER:$TOKEN -H \"Accept: application/vnd.github.v3+json\" \
https://api.github.com/repos/$GITHUB_ORG/$INFRA_SETUP_REPO/branches/staging/protection \
 -d \"{ \
      \\\"restrictions\\\": null,\\\"required_status_checks\\\": null, \
      \\\"required_pull_request_reviews\\\" : {\\\"dismissal_restrictions\\\": {}, \
      \\\"dismiss_stale_reviews\\\": false,\\\"require_code_owner_reviews\\\": true,\
      \\\"required_approving_review_count\\\": 1,\\\"bypass_pull_request_allowances\\\": {}}, \
      \\\"enforce_admins\\\": true
      }\" \
      "

print_and_execute "curl -s -X PUT -u $GITHUB_USER:$TOKEN -H \"Accept: application/vnd.github.v3+json\" \
https://api.github.com/repos/$GITHUB_ORG/$INFRA_SETUP_REPO/branches/prod/protection \
 -d \"{ \
      \\\"restrictions\\\": null,\\\"required_status_checks\\\": null, \
      \\\"required_pull_request_reviews\\\" : {\\\"dismissal_restrictions\\\": {}, \
      \\\"dismiss_stale_reviews\\\": false,\\\"require_code_owner_reviews\\\": true,\
      \\\"required_approving_review_count\\\": 1,\\\"bypass_pull_request_allowances\\\": {}}, \
      \\\"enforce_admins\\\": true
      }\" \
      "

# Creating common setup repo in your org and committing the code from template to it
title_no_wait "Checking if common-setup already exists..."
repo_id_exists=$(curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/json" "https://api.github.com/repos/${GITHUB_ORG}/${TEMPLATE_COMMON_SETUP}" | jq '.id')
if [ ${repo_id_exists} = "null" ]; then
    title_no_wait "${TEMPLATE_COMMON_SETUP} does not exist. Creating it ..."
    print_and_execute "repo_id=$(curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/json" \
        -d "{ \
            \"name\": \"${TEMPLATE_COMMON_SETUP}\", \
            \"private\": true \
        }" \
        -X POST https://api.github.com/orgs/${GITHUB_ORG}/repos | jq '.id')"

    sleep 5
    if [ ${repo_id} = "null" ]; then
        echo "Unable to create git repo.Exiting"
        exit 1
    else
        grep -q "export TEMPLATE_COMMON_SETUP=.*" ${LOG_DIR}/vars.sh || echo -e "export TEMPLATE_COMMON_SETUP=${TEMPLATE_COMMON_SETUP}" >> ${LOG_DIR}/vars.sh
    fi
else
    echo "The repo ${TEMPLATE_COMMON_SETUP} already exists, not creating it"
fi

title_no_wait "Cloning recently created infra repo ${TEMPLATE_COMMON_SETUP}..."
print_and_execute "rm -rf ${TEMP_DIR}/${TEMPLATE_COMMON_SETUP} && git clone  https://${GITHUB_USER}:${TOKEN}@github.com/${GITHUB_ORG}/${TEMPLATE_COMMON_SETUP} ${TEMP_DIR}/${TEMPLATE_COMMON_SETUP}"
if [[ -d ${BASE_DIR}/${TEMPLATE_COMMON_SETUP} ]]; then
    print_and_execute "cd ${TEMP_DIR}/${TEMPLATE_COMMON_SETUP}"
    print_and_execute "git checkout main 2>/dev/null || git checkout -b main"
    print_and_execute "cp -r ${BASE_DIR}/${TEMPLATE_COMMON_SETUP}/* ."
    print_and_execute "git add . && git commit -m \"Adding repo\""
    print_and_execute "git push -u origin main"
else
    title_no_wait "Can not find ${BASE_DIR}/${TEMPLATE_COMMON_SETUP}. Exiting"
    print_and_execute "exit 1"
fi

#Setting up the platform admin project
title_no_wait "Setting project..."
print_and_execute "gcloud config set project ${INFRA_SETUP_PROJECT_ID}"

title_no_wait "Enabling APIs..."
print_and_execute "gcloud services enable cloudresourcemanager.googleapis.com \
cloudbilling.googleapis.com \
cloudbuild.googleapis.com \
iam.googleapis.com \
secretmanager.googleapis.com \
container.googleapis.com \
apikeys.googleapis.com \
cloudidentity.googleapis.com \
gkehub.googleapis.com \
cloudfunctions.googleapis.com \
anthosconfigmanagement.googleapis.com \
servicenetworking.googleapis.com"

print_and_execute "sleep 10"
title_no_wait "Getting project number for ${INFRA_SETUP_PROJECT}"
print_and_execute "INFRA_PROJECT_NUMBER=$(gcloud projects describe ${INFRA_SETUP_PROJECT_ID} --format=json | jq '.projectNumber')"
title_no_wait "Add Cloud build service account as billing account user on the billing account"
print_and_execute "gcloud beta billing accounts get-iam-policy ${BILLING_ACCOUNT_ID} --format=json > ${LOG_DIR}/infra_cloudbuild_billing-iam-policy-input.json
${PYTHON} ${SCRIPT_DIR}/parsePolicy.py ${LOG_DIR}/infra_cloudbuild_billing-iam-policy-input.json ${LOG_DIR}/infra_cloudbuild_billing-iam-policy-output.json billing.user ${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com
print_and_execute "gcloud beta billing accounts set-iam-policy ${BILLING_ACCOUNT_ID} ${LOG_DIR}/infra_cloudbuild_billing-iam-policy-output.json"
title_no_wait "Give cloudbuild service account projectCreator role at Org level...
print_and_execute "gcloud organizations add-iam-policy-binding ${ORG_ID}  --member=serviceAccount:${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/resourcemanager.projectCreator --condition=None"
title_no_wait "Create a custom service account for granting billing user access via Cloud Function and grant it roles"
print_and_execute "gcloud iam service-accounts create ${CUSTOM_SA_BILLING}"
title_no_wait "Grant the custom account billing.admin role on the service account"
print_and_execute "gcloud beta billing accounts get-iam-policy ${BILLING_ACCOUNT_ID} --format=json > ${LOG_DIR}/custom_sa_billing-iam-policy-input.json"
${PYTHON} ${SCRIPT_DIR}/parsePolicy.py ${LOG_DIR}/custom_sa_billing-iam-policy-input.json ${LOG_DIR}/custom_sa_billing-iam-policy-output.json billing.admin ${CUSTOM_SA_BILLING}
print_and_execute "gcloud beta billing accounts set-iam-policy ${BILLING_ACCOUNT_ID} ${LOG_DIR}/custom_sa_billing-iam-policy-output.json"
title_no_wait "Create a custom service account for granting project creator access via Cloud Function and grant it roles"
print_and_execute "gcloud iam service-accounts create ${CUSTOM_SA_PROJECT}"
print_and_execute "gcloud organizations add-iam-policy-binding ${ORG_ID}  --member=\"serviceAccount:${CUSTOM_SA_PROJECT}@${INFRA_SETUP_PROJECT_ID}.iam.gserviceaccount.com\" --role=roles/resourcemanager.organizationAdmin --condition=None"
INFRA_TF_BUCKET="${INFRA_SETUP_PROJECT_ID}-multi-tenant-platform-tf-state"
title_no_wait "Creating GCS bucket for holding terraform state files..."
print_and_execute "gsutil mb -p ${INFRA_SETUP_PROJECT_ID} -l ${REGION}  gs://${INFRA_TF_BUCKET}"
title_no_wait "Create a project to hold common info as secrets ${SECRET_PROJECT_ID} ..."
# Create common secret project
title_no_wait "Checking if ${SECRET_PROJECT_ID} exist already..."
project_id=$(gcloud  projects list  --filter="PROJECT_ID=${SECRET_PROJECT_ID}" --format="value(PROJECT_ID)")
if [[ -z ${project_id} ]]; then
    title_no_wait "${SECRET_PROJECT_ID} does not exist.Creating common secret project ..."
    if [[ -n ${FOLDER_NAME} ]]; then
        print_and_execute "gcloud projects create ${SECRET_PROJECT_ID} \
            --folder ${FOLDER_ID} \
            --name ${SECRET_PROJECT_ID}"
    else
        print_and_execute "gcloud projects create ${SECRET_PROJECT_ID} \
        --name ${SECRET_PROJECT_ID}"
    fi
else
    title_no_wait "${SECRET_PROJECT_ID} already exists, not creating it..."
fi
title_no_wait "Linking billing account to the ${SECRET_PROJECT_ID}..."
print_and_execute "gcloud beta billing projects link ${SECRET_PROJECT_ID} \
--billing-account ${BILLING_ACCOUNT_ID}"
title_no_wait "Enabling APIs in ${SECRET_PROJECT_ID}.."
print_and_execute "gcloud config set project ${SECRET_PROJECT_ID}"
print_and_execute "gcloud services enable secretmanager.googleapis.com cloudfunctions.googleapis.com cloudresourcemanager.googleapis.com  cloudbilling.googleapis.com cloudbuild.googleapis.com"
title_no_wait "Adding secrets to the common secrets project..."
sleep 10
print_and_execute "printf ${TOKEN} | gcloud secrets create github-token --data-file=-"
print_and_execute "printf ${GITHUB_USER} | gcloud secrets create github-user --data-file=-"
print_and_execute "printf ${GITHUB_USER}@github.com | gcloud secrets create github-email --data-file=-"
print_and_execute "printf ${GITHUB_ORG} | gcloud secrets create github-org --data-file=-"
print_and_execute "printf ${BILLING_ACCOUNT_ID} | gcloud secrets create gcp-billingac --data-file=-"
print_and_execute "printf ${ORG_ID} | gcloud secrets create gcp-org --data-file=-"
print_and_execute "printf ${INFRA_SETUP_PROJECT_ID} | gcloud secrets create infra-project-id --data-file=-"
print_and_execute "printf ${ACM_REPO} | gcloud secrets create acm-repo --data-file=-"
print_and_execute "printf ${REGION} | gcloud secrets create infra-region --data-file=-"
print_and_execute "printf ${SEC_REGION} | gcloud secrets create infra-sec-region --data-file=-"
print_and_execute "printf ${SECRET_PROJECT_ID} | gcloud secrets create secrets-project --data-file=-"
print_and_execute "printf \"${CUSTOM_SA_BILLING}@${INFRA_SETUP_PROJECT_ID}.iam.gserviceaccount.com\" | gcloud secrets create billing-granting-sa --data-file=-"
print_and_execute "printf \"${CUSTOM_SA_PROJECT}@${INFRA_SETUP_PROJECT_ID}.iam.gserviceaccount.com\" | gcloud secrets create project-granting-sa --data-file=-"
if [[ -n ${FOLDER_ID} ]]; then
    print_and_execute "printf ${FOLDER_ID} | gcloud secrets create gcp-folder --data-file=-"
else
    print_and_execute "printf \" \" | gcloud secrets create gcp-folder --data-file=-"
fi
#print_and_execute "SECRET_PROJECT_NUMBER=$(gcloud projects describe ${SECRET_PROJECT_ID} --format=json | jq '.projectNumber')"
title_no_wait "Granting Cloud Build SA in ${INFRA_SETUP_PROJECT_ID} project permission to create bucket,Cloud function and service account in common secret project."
print_and_execute "gcloud projects add-iam-policy-binding ${SECRET_PROJECT_ID}  --member=serviceAccount:${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/storage.admin"
print_and_execute "gcloud projects add-iam-policy-binding ${SECRET_PROJECT_ID}  --member=serviceAccount:${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/iam.serviceAccountAdmin"
print_and_execute "gcloud projects add-iam-policy-binding ${SECRET_PROJECT_ID}  --member=serviceAccount:${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/cloudfunctions.developer"
print_and_execute "gcloud projects add-iam-policy-binding ${SECRET_PROJECT_ID}  --member=serviceAccount:${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/resourcemanager.projectIamAdmin"
print_and_execute "gcloud projects add-iam-policy-binding ${SECRET_PROJECT_ID}  --member=serviceAccount:${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/iam.serviceAccountUser"
title_no_wait "Give cloudbuild service account of Platform admin project access to read secrets from  ${SECRET_PROJECT_ID}. It also needs create a secret access ..."
print_and_execute "gcloud projects add-iam-policy-binding ${SECRET_PROJECT_ID}  --member=serviceAccount:${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/secretmanager.admin"

title_no_wait "Granting Cloud Build SA in ${INFRA_SETUP_PROJECT_ID} project permission to create bucket,Cloud function and service account in ${INFRA_SETUP_PROJECT_ID}."
print_and_execute "gcloud projects add-iam-policy-binding ${INFRA_SETUP_PROJECT_ID}  --member=serviceAccount:${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/storage.admin"
print_and_execute "gcloud projects add-iam-policy-binding ${INFRA_SETUP_PROJECT_ID}  --member=serviceAccount:${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/cloudfunctions.developer"
print_and_execute "gcloud projects add-iam-policy-binding ${INFRA_SETUP_PROJECT_ID}  --member=serviceAccount:${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/resourcemanager.projectIamAdmin"
print_and_execute "gcloud projects add-iam-policy-binding ${INFRA_SETUP_PROJECT_ID}  --member=serviceAccount:${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/iam.serviceAccountUser"

title_no_wait "Granting Cloud Build SA in ${INFRA_SETUP_PROJECT_ID} project permission to create VPC for private pools and worker pool"
print_and_execute "gcloud projects add-iam-policy-binding ${INFRA_SETUP_PROJECT_ID}  --member=serviceAccount:${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/compute.networkAdmin"
print_and_execute "gcloud projects add-iam-policy-binding ${INFRA_SETUP_PROJECT_ID}  --member=serviceAccount:${INFRA_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/cloudbuild.workerPoolOwner"

title_no_wait "Grant the custom account for billing cloud function access to read the secrets in the common secrets project"
print_and_execute "gcloud projects add-iam-policy-binding ${SECRET_PROJECT_ID}  --member=serviceAccount:${CUSTOM_SA_BILLING}@${INFRA_SETUP_PROJECT_ID}.iam.gserviceaccount.com --role=roles/secretmanager.secretAccessor"

#Perform sed operation to replace templated variables with real values in common-repo
cd ${TEMP_DIR}/${TEMPLATE_COMMON_SETUP}
title_no_wait "Checkout main branch..."
print_and_execute "git checkout main"
title_no_wait "Replacing variables in ${TEMPLATE_COMMON_SETUP}..."
print_and_execute "find . -type f -exec  sed -i \"s/YOUR_GITHUB_ORG/${GITHUB_ORG}/g\" {} +"
sed -i "s?YOUR_SECRET_PROJECT_ID?${SECRET_PROJECT_ID}?" *.yaml
title_no_wait "Replacing tf bucket in backend.tf in ${TEMPLATE_COMMON_SETUP}..."
sed -i "s/YOUR_PLATFORM_INFRA_TERRAFORM_STATE_BUCKET/${INFRA_TF_BUCKET}/" env/*/backend.tf
title_no_wait "Committing and pushing changes to ${TEMPLATE_COMMON_SETUP}..."

#Perform sed operation to replace templated variables with real values in multi-tenant platform repo
cd ${TEMP_DIR}/${INFRA_SETUP_REPO}
title_no_wait "Checkout dev branch..."
print_and_execute "git checkout dev"
title_no_wait "Replacing variables in ${INFRA_SETUP_REPO}..."
print_and_execute "find . -type f -exec  sed -i \"s/YOUR_GITHUB_ORG/${GITHUB_ORG}/g\" {} +"
print_and_execute "find . -type f -exec  sed -i \"s/YOUR_REGION/${REGION}/g\" {} +"
print_and_execute "sed -i \"s?YOUR_SECRET_PROJECT_ID?${SECRET_PROJECT_ID}?\" *.yaml"
if [[ -n ${FOLDER_ID} ]]; then
    sed -i "s/YOUR_FOLDER_ID/${FOLDER_ID}/"  env/*/variables.tf
else
    sed -i "s/YOUR_FOLDER_ID//"  env/*/variables.tf
fi
title_no_wait "Replacing tf bucket in backend.tf in ${INFRA_SETUP_REPO}..."
sed -i "s/YOUR_PLATFORM_INFRA_TERRAFORM_STATE_BUCKET/${INFRA_TF_BUCKET}/" env/*/backend.tf

title_no_wait "Creating Cloud Build triggers in ${INFRA_SETUP_PROJECT_ID}"
if [[ "${TRIGGER_TYPE,,}" == "webhook" ]]; then
    gcloud config set project ${INFRA_SETUP_PROJECT_ID}
    generate_api_key ${INFRA_SETUP_PROJECT_ID} ${INFRA_PROJECT_NUMBER}
    create_webhook ${INFRA_TRIGGER_NAME} ${INFRA_SETUP_PROJECT_ID} ${INFRA_PROJECT_NUMBER} ${INFRA_SETUP_REPO}
    create_webhook ${COMMON_TRIGGER_NAME} ${INFRA_SETUP_PROJECT_ID} ${INFRA_PROJECT_NUMBER} ${TEMPLATE_COMMON_SETUP}
elif [[ "${TRIGGER_TYPE,,}" == "github" ]]; then
    gcloud config set project ${INFRA_SETUP_PROJECT_ID}
    title_and_wait "ATTENTION : We need to connect Cloud Build in ${INFRA_SETUP_PROJECT_ID} with your github repo. As of now, there is no way of doing it automatically, press ENTER for instructions for doing it manually."
    title_and_wait_step "Go to https://console.cloud.google.com/cloud-build/triggers/connect?project=${INFRA_PROJECT_NUMBER} \
    Select \"Source\" as github and press continue. \
    If it asks for authentication, enter your github credentials. \
    Under \"Select Repository\" , on \"github account\" drop down click on \"+Add\" and choose ${GITHUB_ORG}. \
    Click on \"repository\" drop down and select ${INFRA_SETUP_REPO}. \
    Click the checkbox to agree to the terms and conditions and click connect. \
    Click Done. \
    Repeat the same for connecting ${TEMPLATE_COMMON_SETUP}
    "
    title_no_wait "Creating Cloud Build trigger..."
    print_and_execute "gcloud beta builds triggers create github --name=\"${INFRA_TRIGGER_NAME}\"  --repo-owner=\"${GITHUB_ORG}\" --repo-name=\"${INFRA_SETUP_REPO}\" --branch-pattern=\".*\" --build-config=\"cloudbuild-github.yaml\""
    print_and_execute "gcloud beta builds triggers create github --name=\"${COMMON_TRIGGER_NAME}\"  --repo-owner=\"${GITHUB_ORG}\" --repo-name=\"${TEMPLATE_COMMON_SETUP}\" --branch-pattern=\"main\" --build-config=\"cloudbuild-github.yaml\""
fi

title_no_wait "#######################################################"
title_no_wait "         Finished Bootstrapping platform               "
title_no_wait "#######################################################"

title_no_wait "#######################################################"
title_no_wait "         Bootstrapping Application Factory             "
title_no_wait "#######################################################"


# Create app factory project
title_no_wait "Checking if ${APP_SETUP_PROJECT_ID} exist already..."
project_id=$(gcloud  projects list  --filter="PROJECT_ID=${APP_SETUP_PROJECT_ID}" --format="value(PROJECT_ID)")
if [[ -z ${project_id} ]]; then
    title_no_wait "${APP_SETUP_PROJECT_ID} does not exist.Creating tenant factory project ..."
    if [[ -n ${FOLDER_NAME} ]]; then
        title_no_wait "Creating tenant factory project ${APP_SETUP_PROJECT_ID}..."
        print_and_execute "gcloud projects create ${APP_SETUP_PROJECT_ID} \
            --folder ${FOLDER_ID} \
            --name ${APP_SETUP_PROJECT_ID} \
            --set-as-default"
    else
        title_no_wait "Creating tenant factory project ${APP_SETUP_PROJECT_ID}..."
        print_and_execute "gcloud projects create ${APP_SETUP_PROJECT_ID}  \
        --name ${APP_SETUP_PROJECT_ID} \
        --set-as-default"
    fi
else
    title_no_wait "${APP_SETUP_PROJECT_ID} already exists, not creating it..."
fi

title_no_wait "Linking billing account to the ${APP_SETUP_PROJECT_ID}..."
print_and_execute "gcloud beta billing projects link ${APP_SETUP_PROJECT_ID} \
--billing-account ${BILLING_ACCOUNT_ID}"

#Storing variables in the state file so the script start from where it left off in even of a failure
grep -q "export APP_SETUP_PROJECT_ID.*" ${LOG_DIR}/vars.sh || echo -e "export APP_SETUP_PROJECT_ID=${APP_SETUP_PROJECT_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export APP_SETUP_PROJECT=.*" ${LOG_DIR}/vars.sh || echo -e "export APP_SETUP_PROJECT=${APP_SETUP_PROJECT}" >> ${LOG_DIR}/vars.sh

title_no_wait "Adding git configs"
print_and_execute "git config --global user.email ${GITHUB_USER}@github.com"
print_and_execute "git config --global user.name ${GITHUB_USER}"
# Creating github repos in your org and committing the code from templates
title_no_wait "Checking if ${APP_SETUP_REPO} already exists..."
repo_id_exists=$(curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/json" "https://api.github.com/repos/${GITHUB_ORG}/${APP_SETUP_REPO}" | jq '.id')
if [ ${repo_id_exists} = "null" ]; then
    title_no_wait "${APP_SETUP_REPO} does not exist. Creating it..."
    title_no_wait "Creating app setup repo ${APP_SETUP_REPO} in ${GITHUB_ORG}..."
    print_and_execute "repo_id=$(curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/json" \
        -d "{ \
            \"name\": \"${APP_SETUP_REPO}\", \
            \"private\": true \
        }" \
    -X POST https://api.github.com/orgs/${GITHUB_ORG}/repos | jq '.id')"
    sleep 5
    if [ ${repo_id} = "null" ]; then
        echo "Unable to create git repo.Exiting"
        exit 1
    else
        grep -q "export APP_SETUP_REPO=.*" ${LOG_DIR}/vars.sh || echo -e "export APP_SETUP_REPO=${APP_SETUP_REPO}" >> ${LOG_DIR}/vars.sh
    fi
else
    echo "The repo ${APP_SETUP_REPO} already exists, not creating it"
fi
title_no_wait "Cloning recently created app factory repo..."
print_and_execute "rm -rf ${TEMP_DIR}/${APP_SETUP_REPO} && git clone  https://${GITHUB_USER}:${TOKEN}@github.com/${GITHUB_ORG}/${APP_SETUP_REPO} ${TEMP_DIR}/${APP_SETUP_REPO}"
if [[ -d ${BASE_DIR}/${TEMPLATE_APP_REPO} ]]; then
    print_and_execute "cd ${TEMP_DIR}/${APP_SETUP_REPO}"
    print_and_execute "git checkout main 2>/dev/null || git checkout -b main"
    print_and_execute "cp -r ${BASE_DIR}/${TEMPLATE_APP_REPO}/* ."
    print_and_execute "find . -type f -exec  sed -i "s/YOUR_PROJECT_ID/${PROJECT_ID}/g" {} +"
    print_and_execute "find . -type f -exec  sed -i \"s/YOUR_SECRET_PROJECT_ID/${SECRET_PROJECT_ID}/g\" {} +"
    print_and_execute "git add . && git commit -m \"Adding repo\""
    print_and_execute "git push -u origin main"
else
    title_no_wait "Can not find ${BASE_DIR}/${TEMPLATE_APP_REPO}. Exiting"
    print_and_execute "exit 1"
fi

title_no_wait "Creating other templates..."
for REPO in ${APP_TEMPLATES} ${APP_INFRA_TEMPLATE}
do
    title_no_wait "Checking if ${REPO} already exists in ${GITHUB_ORG}..."
    repo_id_exists=$(curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/json" "https://api.github.com/repos/${GITHUB_ORG}/${REPO}" | jq '.id')
    if [ ${repo_id_exists} = "null" ]; then
        title_no_wait "${REPO} does not exist. Creating it..."
        title_no_wait "Creating app setup repo ${REPO} in ${GITHUB_ORG}..."
        print_and_execute "repo_id=$(curl -s -H "Authorization: token ${TOKEN}" -H "Accept: application/json" \
            -d "{ \
                \"name\": \"${REPO}\", \
                \"private\": true, \
                \"is_template\" : true \
            }" \
        -X POST https://api.github.com/orgs/${GITHUB_ORG}/repos | jq '.id')"
        sleep 5
        if [ ${repo_id} = "null" ]; then
            echo "Unable to create git repo.Exiting"
            exit 1
        fi
    else
        echo "The repo ${REPO} already exists, not creating it"
    fi
    title_no_wait "Cloning recently created repo ${REPO}..."
    print_and_execute "rm -rf ${TEMP_DIR}/${REPO} && git clone  https://${GITHUB_USER}:${TOKEN}@github.com/${GITHUB_ORG}/${REPO} ${TEMP_DIR}/${REPO}"
    if [[ -d ${BASE_DIR}/${REPO} ]]; then
        print_and_execute "cd ${TEMP_DIR}/${REPO}"
        if [ ${REPO} = "infra-template" ]; then
            print_and_execute "git checkout cicd-trigger 2>/dev/null || git checkout -b cicd-trigger"
            print_and_execute "cp -r ${BASE_DIR}/${REPO}/* ."
            print_and_execute "find . -type f -exec  sed -i "s/YOUR_GITHUB_ORG/${GITHUB_ORG}/g" {} +"

            print_and_execute "git add . && git commit -m \"Adding repo\""
            print_and_execute "git push -u origin cicd-trigger"
        else
            print_and_execute "git checkout main 2>/dev/null || git checkout -b main"
            print_and_execute "cp -r ${BASE_DIR}/${REPO}/* ."
            print_and_execute "git add . && git commit -m \"Adding repo\""
            print_and_execute "git push -u origin main"
        fi
    else
    title_no_wait "Can not find ${BASE_DIR}/${REPO}. Exiting"
    print_and_execute "exit 1"
    fi
done

title_no_wait "Setting up App factory project..."
print_and_execute "gcloud config set project ${APP_SETUP_PROJECT_ID}"
print_and_execute "gcloud services enable cloudresourcemanager.googleapis.com \
cloudbilling.googleapis.com \
cloudbuild.googleapis.com \
iam.googleapis.com \
secretmanager.googleapis.com \
container.googleapis.com \
cloudidentity.googleapis.com \
apikeys.googleapis.com"

print_and_execute "sleep 10"

title_no_wait "Getting project number for ${APP_SETUP_PROJECT}"
print_and_execute "APP_PROJECT_NUMBER=$(gcloud projects describe ${APP_SETUP_PROJECT_ID} --format=json | jq '.projectNumber')"

title_no_wait "Adding Application Factory project Number as a secret in common secrets project."
print_and_execute "printf ${APP_PROJECT_NUMBER} | gcloud secrets create application-factory-number --project ${SECRET_PROJECT_ID} --data-file=-"
title_no_wait "Adding Application Factory project ID as a secret in platform admin project."
print_and_execute "printf ${APP_SETUP_PROJECT_ID} | gcloud secrets create application-factory-id --project ${SECRET_PROJECT_ID} --data-file=-"
title_no_wait "Give secret manager admin access to Cloud Build account"
print_and_execute "gcloud projects add-iam-policy-binding ${APP_SETUP_PROJECT_ID} --member=serviceAccount:${APP_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/secretmanager.admin"

title_no_wait "Give workerpool user access on multi tenant project so app factory cloudbuild can use it"
print_and_execute "gcloud projects add-iam-policy-binding ${INFRA_SETUP_PROJECT_ID} --member=serviceAccount:${APP_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/cloudbuild.workerPoolUser"
title_no_wait "Add Cloud build service account as billing account user on the billing account"
print_and_execute "gcloud beta billing accounts get-iam-policy ${BILLING_ACCOUNT_ID} --format=json > ${LOG_DIR}/app_cloudbuild_billing-iam-policy-input.json"
${PYTHON} ${SCRIPT_DIR}/parsePolicy.py ${LOG_DIR}/app_cloudbuild_billing-iam-policy-input.json ${LOG_DIR}/app_cloudbuild_billing-iam-policy-output.json billing.user ${APP_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com
print_and_execute "gcloud beta billing accounts set-iam-policy ${BILLING_ACCOUNT_ID} ${LOG_DIR}/app_cloudbuild_billing-iam-policy-output.json"
print_and_execute "gcloud projects add-iam-policy-binding ${INFRA_SETUP_PROJECT_ID}  --member=serviceAccount:${APP_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/secretmanager.viewer"
title_no_wait "Give cloudbuild service account projectCreator role at Org level..."
print_and_execute "gcloud organizations add-iam-policy-binding ${ORG_ID}  --member=serviceAccount:${APP_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/resourcemanager.projectCreator --condition=None"

APP_TF_BUCKET="${APP_SETUP_PROJECT_ID}-app-factory-tf"
title_no_wait "Creating GCS bucket for holding terraform state files..."
print_and_execute "gsutil mb -p ${APP_SETUP_PROJECT_ID}  -l ${REGION} gs://${APP_TF_BUCKET}"

cd ${TEMP_DIR}/${APP_SETUP_REPO}
title_no_wait "Replacing tf bucket in backend.tf in ${APP_SETUP_REPO}..."
sed -i "s/YOUR_APP_INFRA_TERRAFORM_STATE_BUCKET/${APP_TF_BUCKET}/" backend.tf
title_no_wait "Replacing infra setup project and region in cloudbuild yaml file in ${APP_SETUP_REPO}..."
sed -i "s/YOUR_INFRA_PROJECT_ID/${INFRA_SETUP_PROJECT_ID}/" *.yaml
sed -i "s/YOUR_REGION/${REGION}/" *.yaml
title_no_wait "Replacing github org in github.tf in ${APP_SETUP_REPO}..."
sed -i "s/YOUR_GITHUB_ORG/${GITHUB_ORG}/" github.tf
git config --global user.name ${GITHUB_USER}
git config --global user.email "${GITHUB_USER}github.com"
git add backend.tf github.tf
git commit -m "Replacing github org and GCS bucket"
git push origin

title_no_wait "Give cloudbuild service account of Application Factory access to read secrets from  ${SECRET_PROJECT_ID} ..."
print_and_execute "gcloud config set project ${SECRET_PROJECT_ID}"
print_and_execute "gcloud projects add-iam-policy-binding ${SECRET_PROJECT_ID}  --member=serviceAccount:${APP_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/secretmanager.secretAccessor"
print_and_execute "gcloud projects add-iam-policy-binding ${SECRET_PROJECT_ID}  --member=serviceAccount:${APP_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/secretmanager.viewer"
if [[ "${TRIGGER_TYPE,,}" == "webhook" ]]; then
    print_and_execute "gcloud config set project ${APP_SETUP_PROJECT_ID}"
    generate_api_key ${APP_SETUP_PROJECT_ID} ${APP_PROJECT_NUMBER}
    title_no_wait "Creating webhook ${TEAM_TRIGGER_NAME}"
    create_webhook ${TEAM_TRIGGER_NAME} ${APP_SETUP_PROJECT_ID} ${APP_PROJECT_NUMBER} ${APP_SETUP_REPO}
    title_no_wait "Creating webhook ${APP_TRIGGER_NAME}"
    create_webhook ${APP_TRIGGER_NAME} ${APP_SETUP_PROJECT_ID} ${APP_PROJECT_NUMBER} ${APP_SETUP_REPO}
    title_no_wait "Creating webhook ${PLAN_TRIGGER_NAME}"
    create_webhook ${PLAN_TRIGGER_NAME} ${APP_SETUP_PROJECT_ID} ${APP_PROJECT_NUMBER} ${APP_SETUP_REPO}
    title_no_wait "Creating webhook ${APPLY_TRIGGER_NAME}"
    create_webhook ${APPLY_TRIGGER_NAME} ${APP_SETUP_PROJECT_ID} ${APP_PROJECT_NUMBER} ${APP_SETUP_REPO}

elif [[ "${TRIGGER_TYPE,,}" == "github" ]]; then
    print_and_execute "gcloud config set project ${APP_SETUP_PROJECT_ID}"
    title_and_wait "ATTENTION : We need to connect Cloud Build in ${APP_SETUP_PROJECT_ID} with your github repo. As of now, there is no way of doing it automatically, press ENTER for instructions for doing it manually."
    title_and_wait_step "Go to https://console.cloud.google.com/cloud-build/triggers/connect?project=${APP_SETUP_PROJECT_ID} \
    Select \"Source\" as github and press continue. \
    If it asks for authentication, enter your github credentials. \
    Under \"Select Repository\" , on \"github account\" drop down click on \"+Add\" and choose ${GITHUB_ORG}. \
    Click on \"repository\" drop down and select ${APP_SETUP_REPO}. \
    Click the checkbox to agree to the terms and conditions and click connect. \
    Click Done. \
    "

    title_no_wait "Creating Cloud Build trigger to add terraform files to create github team..."
    print_and_execute "gcloud alpha builds triggers create manual --name=\"${TEAM_TRIGGER_NAME}\" --repo=\"https://github.com/${GITHUB_ORG}/${APP_SETUP_REPO}\" --build-config=\"add-team-tf-files-github-trigger.yaml\" --branch=\"main\" \
    --repo-type=\"GITHUB\" --substitutions \"_TEAM_NAME\"=\"\" "

    title_no_wait "Creating Cloud Build trigger to add terraform files to create application..."
    print_and_execute "gcloud alpha builds triggers create manual --name=\"${APP_TRIGGER_NAME}\" --repo=\"https://github.com/${GITHUB_ORG}/${APP_SETUP_REPO}\" --build-config=\"add-app-tf-files-github-trigger.yaml\" --branch=\"main\" \
    --repo-type=\"GITHUB\" --substitutions \"_APP_NAME\"=\"\",\"_APP_RUNTIME\"=\"\",\"_FOLDER_ID\"=\"${FOLDER_ID}\",\"_INFRA_PROJECT_ID\"=\"${INFRA_SETUP_PROJECT_ID}\",\"_REGION\"=\"${REGION}\",\"_TRIGGER_TYPE\"=\"webhook\",\"_GITHUB_TEAM\"=\"\""

    title_no_wait "Creating Cloud Build trigger for tf-plan..."
    print_and_execute "gcloud alpha builds triggers create manual --name=\"${PLAN_TRIGGER_NAME}\" --repo=\"https://github.com/${GITHUB_ORG}/${APP_SETUP_REPO}\" --branch=\"main\" --build-config=\"tf-plan-github-trigger.yaml\" \
    --repo-type=\"GITHUB\" "

    title_no_wait "Creating Cloud Build trigger for tf-apply..."
    print_and_execute "gcloud alpha builds triggers create manual --name=\"${APPLY_TRIGGER_NAME}\" --repo=\"https://github.com/${GITHUB_ORG}/${APP_SETUP_REPO}\" --branch=\"main\" --build-config=\"tf-apply-github-trigger.yaml\" \
    --repo-type=\"GITHUB\" "
fi


#Committing changes and pushing them to common-setup repo
title_no_wait "Committing and pushing changes to ${TEMPLATE_COMMON_SETUP}..."
cd ${TEMP_DIR}/${TEMPLATE_COMMON_SETUP}
git add .
git config --global user.name ${GITHUB_USER}
git config --global user.email "${GITHUB_USER}github.com"
git commit -m "Initial setup"
git push
title_no_wait "The push to the ${TEMPLATE_COMMON_SETUP} has started the cloudbuild trigger. Go to https://console.cloud.google.com/cloud-build/builds?project=${INFRA_SETUP_PROJECT_ID} ."
#Committing changes and pushing them to multi-tenant platform repo
title_no_wait "Committing and pushing changes to ${INFRA_SETUP_REPO}..."
cd ${TEMP_DIR}/${INFRA_SETUP_REPO}
git add .
git config --global user.name ${GITHUB_USER}
git config --global user.email "${GITHUB_USER}github.com"
git commit -m "IGNOE: Initial setup"
git push
title_no_wait "The push to the ${INFRA_SETUP_REPO} has started the cloudbuild trigger. Go to https://console.cloud.google.com/cloud-build/builds?project=${INFRA_SETUP_PROJECT_ID} ."
title_no_wait "Removing temp directory"
print_and_execute "rm -rf ${TEMP_DIR}"
title_no_wait "#######################################################"
title_no_wait "      Finished Bootstrapping Application Factory       "
title_no_wait "#######################################################"

title_no_wait "#######################################################"
title_no_wait "Multi-tenant admin project  : ${INFRA_SETUP_PROJECT_ID}"
title_no_wait "Automation workflow project : ${SECRET_PROJECT_ID}"
title_no_wait "Application Factory project : ${APP_SETUP_PROJECT_ID}"
title_no_wait "#######################################################"
