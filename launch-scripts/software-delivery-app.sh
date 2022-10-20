#!/usr/bin/env bash

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

shopt -s expand_aliases
# Verify that the scripts are being run from Linux and not Mac
if [[ $OSTYPE != "linux-gnu" ]]; then
    echo "ERROR: This script and consecutive set up scripts have only been tested on Linux. Currently, only Linux (debian) is supported. Please run in Cloud Shell or in a VM running Linux".
    exit;
fi

export SCRIPT_DIR=$(dirname $(readlink -f $0 2>/dev/null) 2>/dev/null || echo "${PWD}/$(dirname $0)")
PROJECT_ID_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1)
START_DIR=${PWD}
BASE_DIR="${SCRIPT_DIR}/../"

# Create a logs folder and file and send stdout and stderr to console and log file 
LOG_DIR=${SCRIPT_DIR}/../../logs/app/
mkdir -p ${LOG_DIR}
TEMP_DIR="${BASE_DIR}/../temp"
mkdir -p ${TEMP_DIR}

if [ ! -f ${LOG_DIR}/vars.sh ]; then
    cp ${SCRIPT_DIR}/vars.sh ${LOG_DIR}/vars.sh
else
    source ${LOG_DIR}/vars.sh
fi
export LOG_FILE=${LOG_DIR}/app-factory-bootstrap-$(date +%s).log
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
read -p "$(echo -e "Please provide Folder Name. If you created your multi-tenant platform in a folder, provide that folder name : ")" FOLDER_NAME

# Ensure infra setup project name is defined
while [ -z ${INFRA_SETUP_PROJECT} ]
    do
    read -p "$(echo -e "Please provide the ID of multi-tenant admin project: ")" INFRA_SETUP_PROJECT
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

# Ensure IAM group name is defined
while [ -z ${IAM_GROUP} ]
    do
    read -p "$(echo -e "Please provide the DevOps IAM group name you created as part of multi-tenant platform setup: ")" IAM_GROUP
    done

# Ensure REGION is defined
while [ -z ${REGION} ]
    do
    read -p "$(echo -e "Please provide the region where resources will be created: ")" REGION
    done

while [ -z ${TRIGGER_TYPE} ]
    do
    read -p "$(echo -e "Enter \"webhook\" for creating webhook triggers or \"github\" for github trigger: ")" TRIGGER_TYPE
    done

TEMPLATE_APP_REPO="app-factory-template"
CUSTOM_SA="devops-sa-${PROJECT_ID_SUFFIX}"
GITHUB_SECRET_NAME="github-token-app"
TEAM_TRIGGER_NAME="add-team-files"
APP_TRIGGER_NAME="create-app"
PLAN_TRIGGER_NAME="tf-plan"
APPLY_TRIGGER_NAME="tf-apply"
APP_TEMPLATES=$(ls ${BASE_DIR} | grep  -- "app-template-")
APP_INFRA_TEMPLATE="infra-template"
TIMESTAMP=$(date "+%Y%m%d%H%M%S")
SA_FOR_API_KEY="api-key-sa-${TIMESTAMP}"

if [[ -z ${APP_SETUP_PROJECT_ID} ]]; then
    APP_SETUP_PROJECT_ID=${APP_SETUP_PROJECT}-${PROJECT_ID_SUFFIX}
fi 

title_no_wait "STARTING"
# Verify that the folder exist if the FOLDER_NAME was not entered blank
if [[ -n ${FOLDER_NAME} ]]; then 
    title_no_wait "Verifying the folder ${FOLDER_NAME} exists..."
    print_and_execute "folder_flag=$(gcloud resource-manager folders list --organization ${ORG_ID} | grep ${FOLDER_NAME} | wc -l)"
    if [ ${folder_flag} -eq 0 ]; then
        error_no_wait "${FOLDER_NAME} does not exist"
        exit 1
    else 
        FOLDER_ID=$(gcloud resource-manager folders list --organization=${ORG_ID} --filter="display_name=${FOLDER_NAME}" --format="value(ID)")
        grep -q "export FOLDER_ID.*" ${LOG_DIR}/vars.sh || echo -e "export FOLDER_ID=${FOLDER_ID}" >> ${LOG_DIR}/vars.sh
    fi
fi

# Create app setup project
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
grep -q "export INFRA_SETUP_PROJECT.*" ${LOG_DIR}/vars.sh || echo -e "export INFRA_SETUP_PROJECT=${INFRA_SETUP_PROJECT}" >> ${LOG_DIR}/vars.sh
grep -q "export APP_SETUP_PROJECT_ID.*" ${LOG_DIR}/vars.sh || echo -e "export APP_SETUP_PROJECT_ID=${APP_SETUP_PROJECT_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export APP_SETUP_PROJECT=.*" ${LOG_DIR}/vars.sh || echo -e "export APP_SETUP_PROJECT=${APP_SETUP_PROJECT}" >> ${LOG_DIR}/vars.sh
grep -q "export BILLING_ACCOUNT_ID=.*" ${LOG_DIR}/vars.sh || echo -e "export BILLING_ACCOUNT_ID=${BILLING_ACCOUNT_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export ORG_NAME=.*" ${LOG_DIR}/vars.sh || echo -e "export ORG_NAME=${ORG_NAME}" >> ${LOG_DIR}/vars.sh
grep -q "export ORG_ID=.*" ${LOG_DIR}/vars.sh|| echo -e "export ORG_ID=${ORG_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export FOLDER_NAME=.*" ${LOG_DIR}/vars.sh || echo -e "export FOLDER_NAME=${FOLDER_NAME}" >> ${LOG_DIR}/vars.sh
grep -q "export FOLDER_ID=.*" ${LOG_DIR}/vars.sh || echo -e "export FOLDER_ID=${FOLDER_ID}" >> ${LOG_DIR}/vars.sh
grep -q "export GITHUB_USER=.*" ${LOG_DIR}/vars.sh || echo -e "export GITHUB_USER=${GITHUB_USER}" >> ${LOG_DIR}/vars.sh
grep -q "export TOKEN=.*" ${LOG_DIR}/vars.sh || echo -e "export TOKEN=${TOKEN}" >> ${LOG_DIR}/vars.sh
grep -q "export GITHUB_ORG=.*" ${LOG_DIR}/vars.sh || echo -e "export GITHUB_ORG=${GITHUB_ORG}" >> ${LOG_DIR}/vars.sh
grep -q "export REGION=.*" ${LOG_DIR}/vars.sh || echo -e "export REGION=${REGION}" >> ${LOG_DIR}/vars.sh
if [[ "${TRIGGER_TYPE,,}" == "webhook" ]] || [[ "${TRIGGER_TYPE,,}" == "github" ]]; then
    grep -q "export TRIGGER_TYPE=.*" ${LOG_DIR}/vars.sh || echo -e "export TRIGGER_TYPE=${TRIGGER_TYPE}" >> ${LOG_DIR}/vars.sh
else
   title_no_wait "The trigger type ${TRIGGER_TYPE} is invalid. Specify webhook or github"
   exit 1
fi

generate_api_key () {
    title_no_wait "Creating a Service Account for creating an API key ..."
    print_and_execute "gcloud iam service-accounts create ${SA_FOR_API_KEY}  --display-name \"API Key ${SA_FOR_API_KEY}\""

    title_no_wait "Granting access to cloudbuild SA for accessing the API key ..."
    print_and_execute "gcloud projects add-iam-policy-binding ${APP_SETUP_PROJECT_ID} \
                       --member serviceAccount:${SA_FOR_API_KEY}@${APP_SETUP_PROJECT_ID}.iam.gserviceaccount.com \
                       --role roles/serviceusage.apiKeysAdmin"

    title_no_wait "Creating credentials for the SA ..."
    print_and_execute "gcloud iam service-accounts keys create ~/credentials.json \
                       --iam-account ${SA_FOR_API_KEY}@${APP_SETUP_PROJECT_ID}.iam.gserviceaccount.com"

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
        print_and_execute "alias gcurl='curl -S -H \"$(oauth2l header --json ~/credentials.json cloud-platform userinfo.email)\" -H \"Content-Type: application/json\"'"
    fi

    title_no_wait "checking if we are all set to create API key ..."
    print_and_execute "type gcurl"
    if [ $? -ne 0 ]; then
        title_no_wait "gcurl alias not set. Problem in using oauth2l. Exiting"
        exit 1
    fi

    title_no_wait "Creating a API key for webhook ..."
    print_and_execute "operation_id=$(gcurl https://apikeys.googleapis.com/v2/projects/${APP_PROJECT_NUMBER}/locations/global/keys -X POST -d '{"displayName" : "webhook","restrictions": {"api_targets": [{"service": "cloudbuild.googleapis.com"}]}}' | jq .name)"
    title_no_wait "Polling for the operation to complete ..."
    status="false"
    while  [ ${status} != "true" ]
    do
        title_no_wait "Waiting for operation to create API to complete. Sleeping for 5"
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
    echo "Trigger is $trigger"
    title_no_wait "Creating a secret for webhook ..."
    SECRET_NAME=webhook-secret-${trigger}
    SECRET_VALUE=$(sed "s/[^a-zA-Z0-9]//g" <<< $(openssl rand -base64 15))
    SECRET_PATH=projects/${APP_PROJECT_NUMBER}/secrets/${SECRET_NAME}/versions/1
    print_and_execute "printf ${SECRET_VALUE} | gcloud secrets create ${SECRET_NAME} --data-file=-"
    title_no_wait "Providing read access to Cloudbuild service account on the secret ..."
    print_and_execute "gcloud secrets add-iam-policy-binding ${SECRET_NAME} \
         --member=serviceAccount:service-${APP_PROJECT_NUMBER}@gcp-sa-cloudbuild.iam.gserviceaccount.com \
         --role='roles/secretmanager.secretAccessor'"

    title_no_wait "Creating a webhook trigger ..."
    if [ "${trigger}" = "${TEAM_TRIGGER_NAME}" ]; then
        print_and_execute "gcloud alpha builds triggers create webhook --name=\"${TEAM_TRIGGER_NAME}\"  --inline-config=\"${BASE_DIR}/${TEMPLATE_APP_REPO}/add-team-tf-files-webhook.yaml\" --secret=${SECRET_PATH} --substitutions='_REPO_NAME=${APP_SETUP_REPO},_TEAM_NAME=\$(body.message.team),_GITHUB_SECRET_NAME=${GITHUB_SECRET_NAME},_GITHUB_ORG=${GITHUB_ORG},_GITHUB_USER=${GITHUB_USER}'"
    elif [ "${trigger}" = "${APP_TRIGGER_NAME}" ]; then
        print_and_execute "gcloud alpha builds triggers create webhook --name=\"${APP_TRIGGER_NAME}\"  --inline-config=\"${BASE_DIR}/${TEMPLATE_APP_REPO}/add-app-tf-files-webhook.yaml\" --secret=${SECRET_PATH} --substitutions='_REPO_NAME=${APP_SETUP_REPO},_APP_NAME=\$(body.message.app),_APP_RUNTIME=\$(body.message.runtime),_GITHUB_SECRET_NAME=${GITHUB_SECRET_NAME},_GITHUB_ORG=${GITHUB_ORG},_GITHUB_USER=${GITHUB_USER},_SA_TO_IMPERSONATE="${CUSTOM_SA}@${APP_SETUP_PROJECT_ID}.iam.gserviceaccount.com",_INFRA_PROJECT_ID=${INFRA_SETUP_PROJECT},_REGION=${REGION},_TRIGGER_TYPE=\$(body.message.trigger_type),_GITHUB_TEAM=\$(body.message.github_team),_FOLDER_ID=${FOLDER_ID}'"
    elif [ "${trigger}" = "${PLAN_TRIGGER_NAME}" ]; then
        print_and_execute "gcloud alpha builds triggers create webhook --name=\"${PLAN_TRIGGER_NAME}\"  --inline-config=\"${BASE_DIR}/${TEMPLATE_APP_REPO}/tf-plan-webhook.yaml\" --secret=${SECRET_PATH} --substitutions='_GITHUB_SECRET_NAME=${GITHUB_SECRET_NAME},_GITHUB_USER=${GITHUB_USER},_REPO_NAME=${APP_SETUP_REPO},_GITHUB_ORG=${GITHUB_ORG}'"
    elif [ "${trigger}" = "${APPLY_TRIGGER_NAME}" ]; then
        print_and_execute "gcloud alpha builds triggers create webhook --name=\"${APPLY_TRIGGER_NAME}\"  --inline-config=\"${BASE_DIR}/${TEMPLATE_APP_REPO}/tf-apply-webhook.yaml\" --secret=${SECRET_PATH} --substitutions='_GITHUB_SECRET_NAME=${GITHUB_SECRET_NAME},_GITHUB_USER=${GITHUB_USER},_REPO_NAME=${APP_SETUP_REPO},_GITHUB_ORG=${GITHUB_ORG}'"
    else
        title_no_wait "Invalid trigger name passed"
        print_and_execute "exit 1"
    fi
    ## Retrieve the URL
    WEBHOOK_URL="https://cloudbuild.googleapis.com/v1/projects/${PROJECT_ID}/triggers/${trigger}:webhook?key=${API_KEY}&secret=${SECRET_VALUE}"

    title_no_wait "Creating a github trigger ..."

    print_and_execute "curl -H \"Authorization: token ${TOKEN}\" \
     -d '{\"config\": {\"url\": \"${WEBHOOK_URL}\", \"content_type\": \"json\"},\"active\": false,\"events\": [\"delete\"]}' \
     -X POST https://api.github.com/repos/$GITHUB_ORG/$APP_SETUP_REPO/hooks"

}

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

title_no_wait "Setting up App infra project..."
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

title_no_wait "Give secret manager admin access to Cloud Build account"
print_and_execute "gcloud projects add-iam-policy-binding ${APP_SETUP_PROJECT_ID} --member=serviceAccount:${APP_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/secretmanager.admin"
title_no_wait "Give iam security admin access to Cloud Build account"
print_and_execute "gcloud projects add-iam-policy-binding ${APP_SETUP_PROJECT_ID} --member=serviceAccount:${APP_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/iam.securityAdmin"
title_no_wait "Give service usage consumer access to Cloud Build account"
print_and_execute "gcloud projects add-iam-policy-binding ${APP_SETUP_PROJECT_ID} --member=serviceAccount:${APP_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/serviceusage.serviceUsageConsumer"

title_no_wait "Checking if IAM Group already exists..."
print_and_execute "group_id_exists=$(gcloud beta identity groups describe "${IAM_GROUP}@${ORG_NAME}" --format=json | jq '.name' | tr '"' ' ' | awk -F '/' '{print $2}')"
if [[ -z ${group_id_exists} ]]; then
    title_no_wait "${IAM_GROUP} does not exist. Exiting..."
    exit 1
else
    title_no_wait "Add Cloud build service account to the IAM group"
    print_and_execute "gcloud identity groups  memberships add --group-email="${IAM_GROUP}@${ORG_NAME}" --member-email=${APP_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
    print_and_execute "gcloud identity groups  memberships modify-membership-roles --group-email="${IAM_GROUP}@${ORG_NAME}" --member-email=${APP_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --add-roles=OWNER"
    grep -q "export IAM_GROUP=.*" ${LOG_DIR}/vars.sh || echo -e "export IAM_GROUP=${IAM_GROUP}" >> ${LOG_DIR}/vars.sh

fi

title_no_wait "Create a custom service account"
print_and_execute "gcloud iam service-accounts create ${CUSTOM_SA}"
title_no_wait "Allow customer service account to be impersonated by Cloud Build SA"
gcloud iam service-accounts add-iam-policy-binding \
    ${CUSTOM_SA}@${APP_SETUP_PROJECT_ID}.iam.gserviceaccount.com \
 --member="serviceAccount:${APP_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/iam.serviceAccountTokenCreator"

title_no_wait "Add custom service account to the IAM group"
print_and_execute "gcloud identity groups  memberships add --group-email="${IAM_GROUP}@${ORG_NAME}" --member-email=${CUSTOM_SA}@${APP_SETUP_PROJECT_ID}.iam.gserviceaccount.com"
print_and_execute "gcloud identity groups  memberships modify-membership-roles --group-email="${IAM_GROUP}@${ORG_NAME}" --member-email=${CUSTOM_SA}@${APP_SETUP_PROJECT_ID}.iam.gserviceaccount.com --add-roles=MANAGER"

title_no_wait "Add Cloud build service account as billing account user on the org"
print_and_execute "gcloud organizations add-iam-policy-binding ${ORG_ID}  --member=serviceAccount:${APP_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/billing.user --condition=None"

title_no_wait "Give cloudbuild service account projectCreator role at Org level..."
print_and_execute "gcloud organizations add-iam-policy-binding ${ORG_ID}  --member=serviceAccount:${APP_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/resourcemanager.projectCreator --condition=None"

title_no_wait "Give cloudbuild service account SecurityAdmin role at Org level..."
print_and_execute "gcloud organizations add-iam-policy-binding ${ORG_ID} --member=serviceAccount:${APP_PROJECT_NUMBER}@cloudbuild.gserviceaccount.com --role=roles/iam.securityAdmin --condition=None"

title_no_wait "Adding github token to secret manager..."
print_and_execute "printf ${TOKEN} | gcloud secrets create ${GITHUB_SECRET_NAME} --data-file=-"

APP_TF_BUCKET="${APP_SETUP_PROJECT_ID}-app-factory-tf"

title_no_wait "Creating GCS bucket for holding terraform state files..."
print_and_execute "gsutil mb -p ${APP_SETUP_PROJECT_ID}  -l ${REGION} gs://${APP_TF_BUCKET}"

cd ${TEMP_DIR}/${APP_SETUP_REPO}
title_no_wait "Replacing tf bucket in backend.tf in ${APP_SETUP_REPO}..."
sed -i "s/YOUR_APP_INFRA_TERRAFORM_STATE_BUCKET/${APP_TF_BUCKET}/" backend.tf
title_no_wait "Replacing github org in github.tf in ${APP_SETUP_REPO}..."
sed -i "s/YOUR_GITHUB_ORG/${GITHUB_ORG}/" github.tf
git config --global user.name ${GITHUB_USER}
git config --global user.email "${GITHUB_USER}github.com"
git add backend.tf github.tf
git commit -m "Replacing github org and GCS bucket"
git push origin

if [[ "${TRIGGER_TYPE,,}" == "webhook" ]]; then
    generate_api_key
    title_no_wait "Creating webhook ${TEAM_TRIGGER_NAME}"
    create_webhook "${TEAM_TRIGGER_NAME}"
    title_no_wait "Creating webhook ${APP_TRIGGER_NAME}"
    create_webhook "${APP_TRIGGER_NAME}"
    title_no_wait "Creating webhook ${PLAN_TRIGGER_NAME}"
    create_webhook "${PLAN_TRIGGER_NAME}"
    title_no_wait "Creating webhook ${APPLY_TRIGGER_NAME}"
    create_webhook "${APPLY_TRIGGER_NAME}"

elif [[ "${TRIGGER_TYPE,,}" == "github" ]]; then
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
    --repo-type=\"GITHUB\" --substitutions \"_GITHUB_SECRET_NAME\"=\"${GITHUB_SECRET_NAME}\",\"_GITHUB_ORG\"=\"${GITHUB_ORG}\",\"_GITHUB_USER\"=\"${GITHUB_USER}\",\"_TEAM_NAME\"=\"\" "

    title_no_wait "Creating Cloud Build trigger to add terraform files to create appliction..."
    print_and_execute "gcloud alpha builds triggers create manual --name=\"${APP_TRIGGER_NAME}\" --repo=\"https://github.com/${GITHUB_ORG}/${APP_SETUP_REPO}\" --build-config=\"add-app-tf-files-github-trigger.yaml\" --branch=\"main\" \
    --repo-type=\"GITHUB\" --substitutions \"_APP_NAME\"=\"\",\"_APP_RUNTIME\"=\"\",\"_FOLDER_ID\"=\"${FOLDER_ID}\",\"_GITHUB_ORG\"=\"${GITHUB_ORG}\",\"_GITHUB_USER\"=\"${GITHUB_USER}\",\"_INFRA_PROJECT_ID\"=\"${INFRA_SETUP_PROJECT}\",\"_SA_TO_IMPERSONATE\"=\"${CUSTOM_SA}@${APP_SETUP_PROJECT_ID}.iam.gserviceaccount.com\",\"_GITHUB_SECRET_NAME\"=\"${GITHUB_SECRET_NAME}\",\"_REGION\"=\"${REGION}\",\"_TRIGGER_TYPE\"=\"webhook\",\"_GITHUB_TEAM\"=\"\""

    title_no_wait "Creating Cloud Build trigger for tf-plan..."
    print_and_execute "gcloud alpha builds triggers create manual --name=\"${PLAN_TRIGGER_NAME}\" --repo=\"https://github.com/${GITHUB_ORG}/${APP_SETUP_REPO}\" --branch=\"main\" --build-config=\"tf-plan-github-trigger.yaml\" \
    --repo-type=\"GITHUB\" --substitutions \"_GITHUB_SECRET_NAME\"=\"${GITHUB_SECRET_NAME}\",\"_GITHUB_USER\"=\"${GITHUB_USER}\" "

    title_no_wait "Creating Cloud Build trigger for tf-apply..."
    print_and_execute "gcloud alpha builds triggers create manual --name=\"${APPLY_TRIGGER_NAME}\" --repo=\"https://github.com/${GITHUB_ORG}/${APP_SETUP_REPO}\" --branch=\"main\" --build-config=\"tf-apply-github-trigger.yaml\" \
    --repo-type=\"GITHUB\" --substitutions \"_GITHUB_SECRET_NAME\"=\"${GITHUB_SECRET_NAME}\",\"_GITHUB_USER\"=\"${GITHUB_USER}\" "
fi

title_no_wait "Removing temp directory"
print_and_execute "rm -rf ${TEMP_DIR}"
title_no_wait "FINISHED"
