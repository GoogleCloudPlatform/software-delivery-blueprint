# Overview

`launch-scripts` contains shell script `bootstrap.sh` that is used to bootstrap the software delivery platform. This script is intended to be executed one time to initialize Application Factory and Multi-tenant Admin components of the blueprint. Once deployed updates to those components are expected to be made directly in the respective component.

## Table of Contents

- [Overview](#overview)
    - [Table of Contents](#table-of-contents)
    - [bootstrap.sh](#bootstrapsh)
        - [Prerequisites](#prerequisites)
        - [Execute](#execute)
    - [Usage](#usage)

## bootstrap.sh

`bootstrap.sh` is used to create:

1. The projects and infrastructure necessary to manage the multi-tenant infrastructure which includes:

   -   Multi-tenant admin project
       - Infrastructure as Code pipeline
   -   Git repositories hydrated from:
       -   [acm-template][acm-template]
       -   [platform-template][platform-template]
       -   [terraform-modules][terraform-modules]
   
       ![multi-tenant-admin](../resources/multi-tenant-admin.png)

       The above diagram depicts the resources deployed and their connections. For more details on the function of the Multi-tenant Admin Project refer to the [platform-template readme][platform-architecture].

2. Application factory, which automates the process of creating applications, teams and landing zones in the software delivery platform:

   -   Application factory project
       - Cloud Build triggers:
         - create a application
         - manage GitHub teams
         - plan/apply Terraform used to managed applications and teams
   -   Git repositories hydrated from:
       -   [app-factory-template][app-factory-template]
       -   [app-template-golang][app-template-golang]
       -   [app-template-java][app-template-java]
       -   [app-template-python][app-template-python]
       -   [infra-template][infra-template]

       ![app-factory-project](../resources/app-factory-project.png)

        The above diagram depicts the resources deployed and their connections.  For more details on the function of the Application Factory refer to the [app-factory-template readme][app-factory-architecture].

### Prerequisites

1. Create a GCP project. 
2. The user executing the script requires the following IAM roles and permissions.
    - Project Owner
3.  The script will prompt for the following information.

| Input Value              | Description
|--------------------------| --------------------
| Multi-tenant IaC Repo    | Name of the git repository will be created and platform-template should be hydrated into.
| GitHub User              | GitHub username that can be used throughout the blueprint for interacting with GitHub.
| GitHub Access Token      | GitHub access token for the specified user, must have the following permissions: **repo:** Full control of private repositories, **delete_repo:** Delete reposistories, **admin:org:** Full control of orgs and teams, read and write org projects and **admin:repo_hook:** Full control of repository hooks.
| GitHub Organization      | The name of your GitHub Organization
| Region                   | The region where the resources are created.
| Secondary Region         | Secondary region for resources that are created in multiple regions.
| Cloud Build Trigger Type | Options: webhook or github. This specifies which type of Cloud Build triggers should be created in the multi-tenant admin and application factory projects.
| Application Factory Repo | Name of the git repository will be created and app-factory-template should be hydrated into.

### Execute

1.  Open cloudshell or any terminal that has gcloud installed.
2.  Authenticate:
    - `gcloud auth login --no-launch-browser`
    - The above command will generate a link, click on it, enter password if needed and you will get an access code.
    - Go back to cloudshell/terminal and enter the access code to authenticate.
3.  Clone the repo branch `single-project-blueprint` from the blueprint repo.

    `git clone -b single-project-blueprint https://github.com/GoogleCloudPlatform/software-delivery-blueprint.git`

4.  `cd software-delivery-blueprint/launch-scripts`
5.  `./bootstrap.sh` the script will prompt for the inputs listed in the prerequistes section. Alternatively, you can provide these inputs in vars.sh under launch-script directory by copying the following text and replacing the placeholders. Then run ./bootstrap.sh. The script sources vars.sh so it will fetch the inputs from there.
```
export INFRA_SETUP_REPO=<Name of the git repository where the platform-template will be cloned and hydrated into>
export APP_SETUP_REPO=<Name of the git repository where the app-factory-template will be cloned and hydrated into>
export GITHUB_USER=<GitHub username>
export TOKEN=<GitHub access token, must have the following permissions: **repo:** Full control of private repositories, **delete_repo:** Delete reposistories, **admin:org:** Full control of orgs and teams, read and write org projects and **admin:repo_hook:** Full control of repository hooks.>
export GITHUB_ORG=<The name of your GitHub Organization>
export REGION=<The region where the resources are created>
export SEC_REGION=<Secondary region for resources that are created in multiple regions>
export TRIGGER_TYPE=<webhook or github>
```
Once the script is completed, you will see a Cloud Build pipeline running in the newly created multi-tenant admin project. A dev deployment of the multi-tenant infrastructure will be completed after the pipeline completes. To deploy the remaining environments follow the workflow from the  [platform-template readme][platform-template-pipeline].

## Usage

Copyright 2022 Google. This software is shared as sample code and not intended
for production use and provided as-is, without warranty or representation for
any use or purpose. Your use of it is discretionary and subject to your
agreement with Google.

<!-- LINKS: https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[acm-template]: ../acm-template/
[app-factory-template]: ../app-factory-template/
[app-factory-architecture]: ../app-factory-template/README.md#application-factory-architecture
[app-template-golang]: ../app-template-golang/
[app-template-java]: ../app-template-java/
[app-template-python]: ../app-template-python/
[external-accounts]: https://support.google.com/a/answer/9007750?hl=en&ref_topic=25840
[group-manager]: https://support.google.com/a/answer/167094?hl=en&ref_topic=9399820
[infra-template]: ../infra-template/
[platform-template]: ../platform-template/
[platform-architecture]: ../platform-template/README.md#architecture
[terraform-modules]:../terraform-modules/
[workspace-group]: https://support.google.com/a/answer/9400082?hl=en#zippy=%2Cstep-create-a-group
[vars.sh]: ./vars.sh
[platform-template-pipeline]: ../platform-template/README.md#infrastructure-pipeline