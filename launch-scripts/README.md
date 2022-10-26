# Overview

`launch-scripts` contains shell scripts `software-delivery-app.sh` and `software-delivery-infra.sh` that are used to bootstrap the software delivery platform. These scripts are intended to be executed one time to initialize Application Factory and Multi-tenant Admin components of the blueprint. Once deployed updates to those components are expected to be made directly in the respective component.

## Table of Contents

- [Overview](#overview)
  - [Table of Contents](#table-of-contents)
  - [software-delivery-infra.sh](#software-delivery-infrash)
    - [Prerequisites](#prerequisites)
    - [Execute](#execute)
  - [software-delivery-app.sh](#software-delivery-appsh)
    - [Prerequisites](#prerequisites-1)
    - [Execute](#execute-1)
  - [Usage](#usage)
  - [Licensing](#licensing)
  - [Contributing](#contributing)

## software-delivery-infra.sh

`software-delivery-infra.sh` is used to create the projects and infrastructure necessary to manage the multi-tenant infrastructure which includes:

-   Multi-tenant admin project
-   Git repositories hydrated from:
    -   [acm-template][acm-template]
    -   [platform-template][platform-template]
    -   [terraform-modules][terraform-modules]
-   Infrastructure as Code pipeline

![multi-tenant-admin](../resources/multi-tenant-admin.png)

The above diagram depicts the resources deployed and their connections. For more details on the function of the Multi-tenant Admin Project refer to the [platform-template readme][platform-architecture].

### Prerequisites

1.  [Google Workspace group][workspace-group] that allows [external accounts][external-accounts]. This group will be used for the DevOps IAM group, which simplifies access to deploy workloads on the multi-tenant infrastructure. The same group is used for both scripts.

2.  The user executing the script requires the following IAM roles and permissions.

    - Organization Administrator
    - Billing Account Administrator
    - Project Creator
    - Folder Admin only if you pass Folder Name to the script

3.  The script will prompt for the following information.

| Input Value                | Description
| -------------------------- | --------------------
| Organization Name          | The name of your Google Cloud Organization.
| Billing Account ID         | Your 18 character billing account ID in the format of xxxxxx-xxxxxx-xxxxxx.
| Folder Name                | Optional, folder that the multi-tenant admin project should be deployed in. Leave blank to deploy to the top-level of the organization. If the Folder Name provided does not exist, the script will create it first. 
| Multi-tenant Admin Project | Project name that should be used for the multi-tenant IaC pipeline.  The value provided will be appended with 6 random characters.
| Multi-tenant IaC Repo      | Name of the git repository will be created and platform-template should be hydrated into.
| GitHub User                | GitHub username that can be used throughout the blueprint for interacting with GitHub
| GitHub Access Token        | GitHub access token for the specified user, must have the following permissions: **repo:** Full control of private repositories, **delete_repo:** Delete reposistories, **admin:org:** Full control of orgs and teams, read and write org projects and **admin:repo_hook:** Full control of repository hooks.
| GitHub Organization        | The name of your GitHub Organization
| DevOps IAM Group           | This is an IAM provisioned at the organization level which is used to grant service accounts the ability to deploy workloads in to the multi-tenant infrastructure.
| Cloud Build Trigger Type   | Options: **webhook** or **github**. This specifies which type of Cloud Build triggers should be created in the multi-tenant admin project.

### Execute

1.  Open cloudshell or any terminal that has gcloud installed.
2.  Authenticate:
    - `gcloud auth login --no-launch-browser`
    - The above command will generate a link, click on it, enter password if needed and you will get an access code.
    - Go back to cloudshell/terminal and enter the access code to authenticate.
3.  Clone the repo blueprint repo.

    `git clone https://github.com/GoogleCloudPlatform/software-delivery-blueprint.git`

4.  `cd software-delivery-blueprint/launch-scripts`
5.  `./software-delivery-infra.sh` the script will prompt for the inputs listed in the prerequistes section.

Once the script is completed, you will see a Cloud Build pipeline running in the newly created multi-tenant admin project. A dev deployment of the multi-tenant infrastructure will be completed after the pipeline completes. To deploy the remaining environments follow the workflow from the platform-template readme.

## software-delivery-app.sh

`software-delivery-app.sh` is used to create the application factory, which automates the process of creating applications, teams and landing zones in the software delivery platform:

-   Application factory project
-   Git repositories hydrated from:
    -   [app-factory-template][app-factory-template]
    -   [app-template-golang][app-template-golang]
    -   [app-template-java][app-template-java]
    -   [app-template-python][app-template-python]
    -   [infra-template][infra-template]
-   Cloud Build triggers:
    -   create a application
    -   manage GitHub teams
    -   plan/apply Terraform used to managed applications and teams

![app-factory-project](../resources/app-factory-project.png)

The above diagram depicts the resources deployed and their connections.  For more details on the function of the Application Factory refer to the [app-factory-template readme][app-factory-architecture].

### Prerequisites

1.  [Google Workspace group][workspace-group] that allows [external accounts][external-accounts]. This group will be used for the DevOps IAM group, which simplifies access to deploy workloads on the multi-tenant infrastructure. The same group is used for both scripts.

2.  The user executing the script requires the following IAM roles and permissions.

    - Organization Administrator
    - Billing Account Administrator
    - Project Creator
    - Folder Admin only if you pass Folder Name to the script

3.  The script will prompt for the following information.

| Input Value                   | Description
| ----------------------------- | --------------------
| Organization Name             | The name of your Google Cloud Organization.
| Billing Account ID            | Your 18 character billing account ID in the format of xxxxxx-xxxxxx-xxxxxx.
| Folder Name                   | Optional, folder that the application factory project should be deployed in. Leave blank to deploy to the top-level of the organization. Provide the same Folder Name that you used with software-delivery-infra.sh script to create multi-tenant infrastructure.
| Multi-tenant Admin Project ID | Project ID of the multi-tenant admin project that was created from the execution of `software-delivery-infra.sh`.
| Application Factory Project   | Project name that should be used for the application factory.  The value provided will be appended with 6 random characters.
| Application Factory Repo      | Name of the git repository will be created and app-factory-template should be hydrated into.
| GitHub User                   | GitHub username that can be used throughout the blueprint for interacting with GitHub
| GitHub Access Token           | GitHub access token for the specified user, must have the following permissions: **repo:** Full control of private repositories, **delete_repo:** Delete reposistories, **admin:org:** Full control of orgs and teams, read and write org projects and **admin:repo_hook:** Full control of repository hooks.
| GitHub Organization           | The name of your GitHub Organization
| DevOps IAM Group              | This is an IAM provisioned at the organization level which is used to grant service accounts the ability to deploy workloads in to the multi-tenant infrastructure.
| Cloud Build Trigger Type      | Options: **webhook** or **github**. This specifies which type of Cloud Build triggers should be created in the application factory project.

### Execute

1.  Open cloudshell or any terminal that has gcloud installed.
2.  Authenticate:
    - `gcloud auth login --no-launch-browser`
    - The above command will generate a link, click on it, enter password if needed and you will get an access code.
    - Go back to cloudshell/terminal and enter the access code to authenticate.
3.  Clone the repo blueprint repo.

    `git clone https://github.com/GoogleCloudPlatform/software-delivery-blueprint.git`

4.  `cd software-delivery-blueprint/launch-scripts`
5.  `./software-delivery-app.sh` the script will prompt for the inputs listed in the prerequistes section.

Once the script is completed, you will have a new project that contains Cloud Build triggers to create new applications and manage teams in GitHub.

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