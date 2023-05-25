# Overview

This folder is hydrated into a repo called `terraform-modules` during the execution of the [`bootstrap.sh`][software-delivery-infra] script. The purpose of this repository is to store Terraform  modules used throughout the platform. `terraform-modules` contains the modules used by application and IaC pipelines.

Terraform modules enable platform administrators to create shared configuration for infrastructure that encapsulate the best practices for their organization, establishing guardrails for self-service infrastructure.

## Table of Contents

- [Overview](#overview)
  - [Table of Contents](#table-of-contents)
  - [Rendering pattern](#rendering-pattern)
  - [Module catalog](#module-catalog)
  - [Example](#example)
  - [Licensing](#licensing)
  - [Usage](#usage)
  - [Contributing](#contributing)

## Rendering pattern

Some modules in this repository follow a rendering pattern. With that pattern
the module generates some Terraform and commits it back into the
`terraform-modules` repository. The rendered Terraform is typically consumed
by downstream pipelines.

An example of this pattern is with [Cloud Deploy][cloud-deploy] targets. When
provisioning a [Google Kubernetes Engine][gke] (GKE) cluster, it will generate
Terraform that is then used by application projects to create a Cloud Deploy
target, so that the target can be used in a Cloud Deploy pipeline.

## Module catalog

| Name                 | Description
|----------------------| --------------
| acm                  | Installs and configures [Anthos Config Managment][acm] (ACM). This module also creates base cluster and cluster selectors in the ACM repo.
| app-group-admin-seed | Deploys the base project for an application group. This module does the minimum necessary to create the project and establish the IaC pipeline for that application group. The application IaC pipeline takes the responsibility of building out the remainder of the application admin project.
| artifact-registry    | Creates [Artifact Registry][artifact-registry] for an application group.  This module also uses the render pattern to manage IAM access on the registry to allow multi-tenant GKE clusters service account.
| cloud-deploy-targets | This module creates [Cloud Deploy targets][cloud-deploy-target] in application admin projects for use by the [Cloud Deploy pipeline][cloud-deploy-pipeline]. This module also includes a submodule that renders the Terraform to create the Cloud Deploy targets.
| cloud-functions      | This module creates [Cloud Functions][cloud-function] in automation workflow project which will be invoked by Application Factory while creating the apps to provisions access for the apps.
| github-triggers      | Creates [Cloud Build][cloud-build] triggers using the [GitHub application][cloud-build-github].
| gke                  | Deploys [GKE][gke] clusters, typically used in the multi-tenant platform projects.
| landing-zone         | Using the rendering pattern and ACM, this module creates a landing zone in the multi-tenant infrastructure including a namespace, workload identity and network policy.
| manage-repos         | This module contains submodules to create the application and infrastructure as code repostories on GitHub. Additional source control providers could be added here.
| manage-teams         | This modules manages teams and their members in GitHub.
| mci                  | This module enables multi-cluser ingress and multi-cluster service on GKE cluser.
| project              | Create Google Cloud projects and provides a variable to enabled additional Google Cloud APIs as need by the application teams.
| vpc                  | Base module to create VPC networks.
| webhooks             | Creates Cloud Build triggers using [webhooks][cloud-build-webhook].

## Example

```hcl
module "cloud-deploy-target" {
  source                = "git::https://github.com/GITHUB_ORG/terraform-modules.git//cloud-deploy-targets/render"

  git_user              = var.github_user
  git_email             = var.github_email
  git_org               = var.github_org
  github_token          = var.github_token
  git_repo              = "terraform-modules"
  cluster_name          = module.create_gke_1.cluster_name.name
  cluster_path          = local.gke_cluster_id
  location              = local.subnet1.region
  require_approval      = "false"

  depends_on            = [ module.artifact-registry-iam ]
}
```

```hcl
module "cloud-deploy-targets" {
  source = "git::https://github.com/<GITHUB_ORG>/terraform-modules//cloud-deploy-targets"

  service_account = var.clouddeploy_service_account
  project         = var.project_id

  depends_on = [
    module.project-service-cloudresourcemanager
  ]
}
```

```hcl
module "devops" {
    source = "git::https://github.com/<GITHUB_ORG>/terraform-modules.git//manage-teams"

    name = "engineering"
    description = "Team for engineering"
    privacy = "closed"
    parent_team_id = "engineering"
    members = ["github_user1", "github_user2"]
    maintainers = ["github_maint"]
    admin_repositories = ["app-template-java"]
    maintain_repositories = ["app-template-java"]
    push_repositories = ["app-template-java"]
    triage_repositories = ["app-template-java"]
    pull_repositories = ["app-template-golang"]
}
```

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

*   [Contributing guidelines][contributing-guidelines]
*   [Code of conduct][code-of-conduct]

<!-- LINKS: https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributing-guidelines]: CONTRIBUTING.md
[code-of-conduct]: code-of-conduct.md
[software-delivery-infra]: ../launch-scripts/bootstrap.sh
[acm]: https://cloud.google.com/anthos/config-management
[artifact-registry]: https://cloud.google.com/artifact-registry
[cloud-deploy]: https://cloud.google.com/deploy
[cloud-deploy-target]: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/clouddeploy_target
[cloud-deploy-pipeline]: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/clouddeploy_delivery_pipeline
[cloud-build]: https://cloud.google.com/build/docs/overview
[cloud-build-github]: https://cloud.google.com/build/docs/automating-builds/github/connect-repo-github
[cloud-build-webhook]: https://cloud.google.com/build/docs/automate-builds-webhook-events
[gke]: https://cloud.google.com/kubernetes-engine
[secret-manager]: https://cloud.google.com/secret-manager
[cloud-function]: https://cloud.google.com/functions