<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 4.3.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.28.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.28.0 |


## Inputs

| Name | Description                                                                                                                      | Type | Default | Required |
|------|----------------------------------------------------------------------------------------------------------------------------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Name of the application. It will be suffixed with '-infra' to derive the name of the repo that will be connected to the trigger. | `string` | n/a | yes |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | GitHub organization.                                                                                                             | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Id of the application admin project.                                                                                             | `string` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | Service Account to associate Cloud Build trigger with.                                                                           | `string` | n/a | yes |

## Usage

```hcl
module "github-trigger" {
  source          = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//github-triggers/iac"
  project_id      = <Project Id>
  service_account = <SA to be associated with the trigger>
  github_org      = <GitHub org>
  app_name        = "my-app"
  depends_on      = [github_repository.infrastructure_repo]
}
```

## Workflow

While creating an application via Application Factory, if the IaC trigger type for an application is chosen to be GitHub trigger, this module is called by [github-infra-repo module][github-infra-repo] which is invoked from _app-name_.tf files in [Application Factory][application-factory] repo for each application. This module creates a GitHub trigger connected to the [infrastructure repo][infra-repo] of the application.

<!-- LINKS: https://www.markdownguide.org/basic-syntax/#reference-style-links -->

<!-- END_TF_DOCS -->
[github-infra-repo]: ../../manage-repos/github-infra-repo
[application-factory]: ../../../app-factory-template/README.md
[infra-repo]: ../../../app-factory-template/README.md?plain=1#L64
