# Overview

The Application Factory is an example of a golden path, that allows teams to quickly provision application landing zones in the multi-tenant infrstructure and single-tenant infrastructure in a self-service manner. Using the Application Factory developers, devops engineers or platform admins can create code repositories, an application landing zone, application CI/CD pipeline and an infrastructure as code pipeline to manage infrastructure dedicated to the application. The landing zone and infrastructure is created using Terraform and yaml templates defined by platform administrators so best practices are adopted from day 1.

The `app-factory-template` directory contains the structure and Cloud Build triggers that teams will use to create new applications and manage application teams in the software delivery platform. `app-factory-template` folder is hydrated into a repository during the execution of the [`bootstrap.sh`][software-delivery-app] script.

## Table of Contents

- [Overview](#overview)
  - [Table of Contents](#table-of-contents)
  - [Application Factory Architecture](#application-factory-architecture)
    - [Templates](#templates)
      - [Application Template](#application-template)
      - [Team Template](#team-template)
      - [Scripts](#scripts)
    - [Apps](#apps)
    - [Teams](#teams)
    - [Config](#config)
    - [Cloud Build Triggers](#cloud-build-triggers)
  - [Application Factory workflows](#application-factory-workflows)
    - [Create a new Application](#create-a-new-application)
    - [Create a new GitHub team](#create-a-new-github-team)
    - [Delete an application](#delete-an-application)
    - [Delete a team](#delete-a-team)
    - [Manage an Application](#manage-an-application)
      - [Create CICD pipeline of an application](#create-cicd-pipeline-for-the-application-through-iac-cloud-build-trigger)
      - [Deploy an application](#deploy-the-application-through-cicd-cloud-build-trigger)
      - [Change infrastructure of an application](#change-infrastructure-for-the-application)
      - [Change application code of an application](#change-application-code)
      - [Change IaC pipeline of an application](#change-iac-cloud-build-trigger-pipeline)
      - [Change CICD pipeline of an application](#change-cicd-cloud-build-trigger-pipeline)
  - [Licensing](#licensing)
  - [Usage](#usage)
  - [Contributing](#contributing)

## Application Factory Architecture

![app-factory-architecture](../resources/app-factory-architecture.png)

The diagram above shows the components of the Application Factory and their interactions:

1.  Users start the process of creating a new application by providing the application name and runtime to the `create-app` [Cloud Build][cloud-build] trigger.
2.  Cloud Build performs variable substitution in [`application.tf.tpl`][application-tf-tpl] to hydrate Terraform to represent the new application. The hydrated Terraform is committed in the Application Factory's git repository as `<application_name>.tf`.
3.  The `tf-apply` Cloud Build trigger reads the new code and starts the process of deploying new resources.
4.  Applying the Terraform creates new git repos for the application code and application's infrastructure as code off of the runtime's template and `infra-template` respectively. Terraform also hydrates the Kubernetes [landing zone][landing-zone] in the [Anthos Config Management][acm] repo. Finally this process also creates the application's CI/CD project and infrastructure as code Cloud Build trigger.
5.  The application's infrastructure as code Cloud Build trigger creates the CI/CD pipeline for application deployments.
6.  Anthos Config Management deploys the [landing zone][landing-zone] to the multi-tenant GKE clusters that includes a namespace, network policy and workload identity.
7.  The application's CI/CD pipeline performs the initial deployment of the application to the GKE clusters.
8.  Optionally, the application team use the infrastructure as code Cloud Build trigger to deploy projects and additional resources (CloudSQL, Pub/Sub, etc.) to dedicated projects. As a best practice Terraform modules should be provided to application teams for those resources so best practices are automatically applied.

### Templates

`templates` folder contains the templates that are used to populate the `apps` and `teams` folders. When their respective pipelines are run those template are hydrated with the values provided by the application team and platform team.

The templates for applications and teams is intentionally very small and uses the modules defined in [`terraform-modules`][terraform-modules] for the majority of the logic.

#### Application Template

The application template ([`application.tf.tpl`][application-tf-tpl]) is the IaC used to create the following resources.

-   Application CI/CD project
-   Application code repository from the language specific template
-   Application group IaC repository from the [`infra-template`][infra-template]
-   Infrastructure as code Cloud Build trigger in the CI/CD project

#### Team Template

The team template ([`team.tf.tpl`][team-tf-tpl]) is a Terraform snippet that is invoked to manage team structures in GitHub. The Cloud Build trigger `add-team-files` and template enables application teams to self-manage who has access to their respositories. Managing teams as IaC makes it easier for security teams to audit who has access to different respositories.

#### Scripts

The shell scripts under `setup` folder are used to hydrate the templates into actual Terraform files from the `templates`.

### Apps

`apps` will contain the actual hydrated Terraform used to create and manage the applications provisioned on the software delivery platform. The hydrated Terraform is created via the `create-app` Cloud Build trigger in the application factory project.

Defining the applications as Terraform has a number of benefits in the operation of the platform:

1.  There is a central location to see what applications have been provisioned.
2.  The infrastructure as code approach brings consistency to the management process.
3.  Updates to the applcation bases can be broadly applied with little effort by platform administrators.

Once the blueprint is deployed and applications have been provisioned the folder structure will look similar to:

```none
 -  apps
 |--  golang
 |----  application1.tf
 |----  application2.tf
 |--  java
 |----  application3.tf
```

### Teams

`teams` will contain the hyrdated Terraform used to create and manage your teams in GitHub. The hydrated Terraform is created via the `add-team-files` Cloud Build trigger in the application factory project.

By default in `teams` there are two sample templates `engineering.tpl` and `devops.tpl` provided. The templates basical specify who will be the members of the team, which repos will the team have access to and any parent/child relationship of teams (nested teams).

The folder structure under `teams` will reflect the nested structure as you specify in the templates of the teams. For example, if you create a team Engineering and then a child team DevOps the folder structure will look similar to:

```none
 -  teams
 |--  engineering
 |----  devops
```

### Config

The `config` folder contains configurations files used by the `add-team-files` and `create-app` triggers:

-   `app_runtimes_list.txt` is an allow list of type of application runtimes that are supported by Application factory.
-   The files in `team-configs` are the GitHhub teams that you create.

### Cloud Build Triggers

The application factory has four Cloud Build tiggers, each are defined as yaml files in the `app-factory-template`.

1.  `create-app`, this trigger hydrates an application template and stores it in apps folder.
2.  `add-team-files`, this trigger processes the teams config and stores the resulting Terraform in the teams folder.
3.  `tf-plan`, performs a Terraform plan.
4.  `tf-apply`, performs Terraform apply, updating the provisioned applications and teams in GitHub.

The triggers in Application Factory is run with private pool created via [common-setup pipeline][common-setup-pipeline].

Note: The script bootstrap.sh that creates your application factory accepts an input "TRIGGER_TYPE" which can be either `webhook` or `github`. 
If `github` is passed as "TRIGGER_TYPE" to the script, the script creates GitHub triggers in Cloud Build. 
If `webhook` is passed as "TRIGGER_TYPE" to the script, the script creates webhook triggers in Cloud Build. 

The following table shows which configuration file is linked with which trigger in Cloud Build:

| Trigger Name   | If it is a webhook trigger    | If it is a webhook github trigger    |
|----------------|-------------------------------|--------------------------------------|
| create-app     | add-app-tf-files-webhook.yaml | add-app-tf-files-github-trigger.yaml |
| add-team-files | add-app-tf-files-webhook.yaml | add-app-tf-files-github-trigger.yaml |
| tf-plan        | tf-plan-webhook.yaml          | tf-plan-github-trigger.yaml          |
| tf-apply       | tf-apply-webhook.yaml         | tf-apply-github-trigger.yaml         |

Once your application factory has been created, you may delete the configuration files that are no longer required. e.g if you created webhook triggers in Cloud Build,
you can delete the configuration files for github triggers or vice-versa. This is not a mandatory step but is recommended to avoid any confusion.

## Application Factory workflows

The next sections will outline common workflows in the software delivery platform and how to perform them in blueprint.

### Create a new Application

-   Run the trigger `create-app` in the Application factory. You will need to pass the following parameters:
    -   Application name
    -   Runtime language
-   Run the `tf-plan` trigger to verify the actions Terraform will take.
-   Run the `tf-apply` trigger, which will create the new application on the platform.

The `create-app` trigger will generate the Terraform code to spin up a new application and save it in a .tf file with the same name as the application under the runtime language folder. For example, if you run `create-app` trigger to create an application with name as **booking** and **golang** as the runtime language, the trigger will create a file named **booking.tf** under **apps/golang** folder.
Then, running `tf-apply` trigger will take the latest TF code and apply it.

### Create a new GitHub team

-   In `teams` create a new template with the same name as the team you are creating.  For example, to create a team called Operations, you will need to create a file named `operations.tpl` under the `config/teams-config` folder. Note that the names are case-insensitive.
-   Commit and push your changes to the `app-factory` repo, as specified when running the `bootstrap.sh` launch script.
-   Run `add-team-files` trigger in the Application factory. Passing the following parameters:
    -  Team name (It should be the same as the name of the file you committed in previous step.)
-   Run the `tf-plan` trigger to verify the actions Terraform will take.
-   Run the `tf-apply` trigger, which will create the new team in your GitHub organization.

The trigger `add-team-files` will create Terraform code to describing the GitHub team and save it as .tf file under `teams` folder in this repo.
Then, running `tf-apply` trigger will take the latest TF code and apply it.

### Delete an application

If you have already deployed the application using a [Cloud Deploy][cloud-deploy] pipeline or IaC trigger has run successfully at least once, follow these steps to delete the pipelines first:

-   Delete the delivery pipelines corresponding to the application:
    -   `gcloud beta deploy delivery-pipelines delete <pipeline name> --region <region> --force`
-   Find the release targets corresponding to the application:
    -   `gcloud beta deploy targets list --region <region>`
-   Delete the release targets corresponding to the application:
    -   `gcloud beta deploy targets delete <name obtained from the above command> --region <region>`

Once the above steps have been completed or if the application has not been deployed by a Cloud Deploy pipeline, follow the following steps.

-   Delete the .tf file for the application under `apps/<runtime>` folder.
-   Commit and push the change.
-   Run the `tf-plan` trigger to verify the actions Terraform will take.
-   Run the `tf-apply` trigger. It will refresh Terraform state and delete the resource related to the application.

### Delete a team

-   Edit `teams/main.tf` to remove the module reference to the team that you want to delete.
-   Delete the folder named after the team from `teams` directory.
-   Commit and push the changes.
-   Run the `tf-plan` trigger to verify the actions Terraform will take.
-   Run the `tf-apply` trigger. It will refresh Terraform state and delete the GitHub team.

### Manage an Application

#### Application components

When you create an application via Application Factory, you get the following components:

-   A GCP project, the Application Admin project. The name of this project will be _application-name_-tf-admin.
-   Two git repos named _application-name_ and _application-name_-infra. 
    -   The _application-name_ repo is the source code repo that is created from a template based on the type of application you have created. For example, if you created a Java application, the _application-name_ source repo will be cloned from app-template-java template repository.
    -   The _application-name_-infra repo will contain the IaC for building infrastructure and CI/CD pipeline for the application. This is created from infra-template template repository.
-   IaC Cloud Build trigger named `deploy-infra`
    -   `deploy-infra` trigger is connected to _application-name_-infra repo
    -   While creating the application from the Application Factory, you choose TRIGGER_TYPE as either "webhook" or "github" to create `deploy-infra` as a webhook trigger or a GitHub trigger.
  
#### Create CICD pipeline for the application through IaC Cloud Build trigger

-   IaC Cloud Build trigger `deploy-infra` creates the CI/CD pipeline of the application. You can kick-off `deploy-infra` trigger by any of the following ways:
    -   Do a push to _application-name_infra repo.
    -   If the trigger is a **GitHub trigger**, run the trigger manually from Google Cloud console on cicd-trigger branch.
    -   If the trigger is a **webhook trigger**, make a [cURL][curl] call with the webhook endpoint. The webhook endpoint can be obtained from Google Cloud Console when you click open the trigger and go to "show url" section. 
-   Once the trigger has successfully completed, you will have the following components created in the Application Admin project:
    -   A CI/CD Cloud Build trigger named `deploy-app` that is connected to the _application-name_ repository.
    -   An Artifact Registry repo.
    -   Cloud Deploy targets for dev, staging and prod GKE clusters that were created as part of multi-tenant infrastructure.

#### Deploy the application through CICD Cloud Build trigger

-   The `deploy-app` trigger type (webhook or GitHub) will be the same as `deploy-infra`, unless you override it in _applicaton_name-infra repo.
-   You can deploy the application by any of the following ways:
    -   Do a push to _application_ repo.
    -   If the trigger is a **GitHub trigger**, run the trigger manually from Google Cloud console on main branch.
    -   If the trigger is a **webhook trigger**, make a [cURL][curl] call with the webhook endpoint. The webhook endpoint can be obtained from Google Cloud Console when you click open the trigger and go to "show url" section.
-   The trigger will take the code from the main branch of _application-name_ repo and perform the following actions:
    -   Using [Skaffold][skaffold] build a Docker image from source code, storing the Docker image in Artifact Registry.
    -   Invoke a Cloud Deploy pipeline that will deploy the artifacts on the targets which were created by IaC Cloud Build trigger, this step also hydrates [kustomization][kustomize] files from the _application-name_ repo.

#### Change Infrastructure for the application

-   All the infrastructure for the application is created from IaC residing in _application-name_-infra repo.
-   _application-name_-infra repo follows the [branch and folder pattern][next19-infra-as-code] to represent and manage environments. The repo contains four branches and folders cicd-trigger, dev, staging and prod.
    -   Admin project branch (cicd-trigger) :
        The cicd-trigger branch/folder contains the IaC used to maintain the application's CI/CD pipelines including Artifact Registry repo and Cloud Deploy targets.
    -   Environment branches (dev, staging, prod) :
        The other branches/folders represent environments containing infrastructure dedicated to a single application. 
-   Similar to the [multi-tenant infrastructure repo][multi-tenant-repo] you can only push to the default branch i.e cicd-trigger branch for this repo, use pull requests to review and merge changes into the dev, staging and production environments.
-   A push to the repo invokes `deploy-infra` trigger and apply the changes for the

#### Change Application code

-   _application-name_ is the repo that contains the source code.
-   Change the code and commit it. When the commit is pushed to the repo, the `deploy-app` trigger is invoked automatically and deploys the latest code to the required target. 

#### Change IaC Cloud Build trigger pipeline

-   IaC Cloud Build trigger `deploy-infra` is connected to the _application-name_-infra repo.
-   If the trigger was created as a **GitHub trigger**, the `cloudbuild.yaml` in _application-name_-infra repo will be used as configuration file(execution steps) for the trigger. You can change the yaml file if you need to change the trigger's execution steps.
-   If the trigger was created as a **webhook trigger**, the configuration of the trigger will be inline in the Cloud Build trigger. In this scenario you will not need `cloudbuild.yaml` in _application-name_-infra repo so it is recommended to delete it to avoid confusion. To change the `deploy-infra` trigger's execution steps, it is recommended to create a new version of [Terraform module][iac-webhook-terraform-module] that creates the trigger in the Application Factory. Alternatively, you can change it inline by opening the trigger from Google Cloud console or Google Cloud CLI or SDK, not recommended since those update could be overwritten by the Application Factory's next run.

#### Change CICD Cloud Build trigger pipeline

-   CI/CD Cloud Build trigger `deploy-app` is connected to the _application-name_ repo.
-   If the trigger was created as a **GitHub trigger**, the `cloudbuild.yaml` in _application-name_ repo will be used as configuration file(execution steps) for the trigger. You can change the yaml file if you need to change the trigger's execution steps.
-   If the trigger was created as a **webhook trigger**, the configuration of the trigger will be inline in the Cloud Build trigger. In this scenario you will not need `cloudbuild.yaml` in _application-name_-infra repo so it is recommended to delete it to avoid confusion. To change the `deploy-app` trigger's execution steps, it is recommended to create a new version of [Terraform module][application-webhook-terraform-module] that creates the trigger in IaC Cloud Build pipeline. Alternatively, you can change it inline by opening the trigger from Google Cloud console or Google Cloud CLI or SDK, not recommended since those update could be overwritten by the Iac pipeline.

## Licensing

```lang-none
Copyright 2022 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

## Usage

Copyright 2022 Google. This software is shared as sample code and not intended
for production use and provided as-is, without warranty or representation for
any use or purpose. Your use of it is discretionary and subject to your
agreement with Google.

## Contributing

* [Contributing guidelines][contributing-guidelines]
* [Code of conduct][code-of-conduct]

<!-- LINKS: https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributing-guidelines]: CONTRIBUTING.md
[code-of-conduct]: code-of-conduct.md

[acm]: https://cloud.google.com/anthos/config-management
[application-tf-tpl]: templates/application.tf.tpl
[cloud-deploy]: https://cloud.google.com/deploy
[cloud-build]: https://cloud.google.com/build/docs/overview
[curl]: https://curl.se/
[kustomize]: https://kustomize.io/
[infra-template]: ../infra-template/
[landing-zone]: ../platform-template/README.md#application-landing-zones
[team-tf-tpl]: templates/team.tf.tpl
[terraform-modules]: ../terraform-modules/
[skaffold]: https://skaffold.dev/
[software-delivery-app]: ../launch-scripts/bootstrap.sh
[next19-infra-as-code]: https://www.youtube.com/watch?v=3vfXQxWJazM
[multi-tenant-repo]: ../platform-template/#infrastructure-pipeline
[iac-webhook-terraform-module]: ../terraform-modules/webhooks/iac
[application-webhook-terraform-module]: ../terraform-modules/webhooks/application