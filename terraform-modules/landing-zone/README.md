<!-- BEGIN_TF_DOCS -->
## Usage

```hcl
module "landing-zone-render" {
  source                = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//landing-zone/dev"
  git_user              = <GitHub user>
  git_email             = <GitHub user email>
  git_org               = <GitHub org>
  tf_modules_repo       = "terraform-modules"
  cluster_name          = "my-cluster"
  cluster_project_id    = <Clutser project id>
  env                   = "dev"
  index                 = 0
}
```

## Workflow

Pre-requisite : The [landing-zone-render module][landing-zone-render] adds a folder for each environment in this module and creates Terraform files for corresponding GKE cluster inside those folders when multi-tenant infrastructure is created.

This module is called from _app-name_.tf files in [Application Factory][application-factory] repo for each application and performs the following actions as part of landing zone creation for the application:

-   creates Kubernetes yaml files for namespace, Kubernetes Service Account and network-policy and commits them to ACM repo that creates these resources on the GKE clusters.
-   grants permissions to Google Service Account on Kubernetes Service Account to complete workload identity setup. 


<!-- LINKS: https://www.markdownguide.org/basic-syntax/#reference-style-links -->

<!-- END_TF_DOCS -->

[application-factory]: ../../app-factory-template/README.md
[landing-zone-render]: render
[acm]: https://cloud.google.com/anthos/config-management
[acm-template]: ../../acm-template/README.md
