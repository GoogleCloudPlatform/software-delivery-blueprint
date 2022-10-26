<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 4.3.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.28.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | >= 4.3.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 2.1 |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_runtime"></a> [app\_runtime](#input\_app\_runtime) | Type of runtime for the application e.g java or golang or python etc. | `string` | n/a | yes |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application which will also be the name of the repo. | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | List of environments for which the landing zone is to be created. | `list` | n/a | yes |
| <a name="input_github_email"></a> [github\_email](#input\_github\_email) | GitHub user email. | `string` | n/a | yes |
| <a name="input_github_user"></a> [github\_user](#input\_github\_user) | GitHub username. | `string` | n/a | yes |
| <a name="input_ksa"></a> [ksa](#input\_ksa) | K8s service account to be added in the kubernetes files in app repo. | `map` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | K8s namespace to be added in the kubernetes files in app repo. | `map` | n/a | yes |
| <a name="input_org_name_to_clone_template_from"></a> [org\_name\_to\_clone\_template\_from](#input\_org\_name\_to\_clone\_template\_from) | GitHub org where the repo will be created. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Id of the application admin/seed project. | `string` | n/a | yes |
| <a name="input_project_number"></a> [project\_number](#input\_project\_number) | Project number of the application admin/seed project. | `number` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Google Cloud region. | `string` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | CICD Cloud Build SA. | `string` | n/a | yes |
| <a name="input_trigger_type"></a> [trigger\_type](#input\_trigger\_type) | webhook or github trigger. | `string` | `"webhook"` | no |

## Usage

```hcl
module "setup-cicd" {
  source = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//manage-repos/github-app-repo"
  application_name = "my-app"
  org_name_to_clone_template_from = "YOUR_GITHUB_ORG"
  trigger_type = "webhook"
  project_number = 123456789
  project_id = <Project Id>
  service_account = <SA for IaC Cloud Build pipeline>
  app_runtime = "java"
  github_user = <GitHub user>
  github_email = <GitHub user email>
  namespace = "test"
  ksa = "my-kubernetes-sa"
  env = "dev"
  region = "us-central1"
}
```

## Workflow

This module is called from _app-name_.tf files in [Application Factory][application-factory] repo for each application and performs the following actions:

-   sets up [source code repo][application-repo] for the application.
-   optionally creates a webhook or GitHub trigger connected to the source code repo.

<!-- LINKS: https://www.markdownguide.org/basic-syntax/#reference-style-links -->

<!-- END_TF_DOCS -->

[application-factory]: ../../../app-factory-template/README.md
[application-repo]: ../../../app-factory-template/README.md?plain=1#L63
