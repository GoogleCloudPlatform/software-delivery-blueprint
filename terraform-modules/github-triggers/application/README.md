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

| Name | Description                                                                                                      | Type | Default | Required |
|------|------------------------------------------------------------------------------------------------------------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Name of the application which is same as the name of the application repo that will be connected to the trigger. | `string` | n/a | yes |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | Id of the secret holding github access token.                                                                    | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Id of the application admin project.                                                                             | `string` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | Service Account to associate cloudbuild trigger with.                                                            | `string` | n/a | yes |

## Usage

```hcl
module "github-trigger" {
  source          = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//github-triggers/application"
  project_id      = <Project Id>
  service_account = <SA to be associated with the trigger>
  github_org      = <GitHub org>
  app_name        = "my-app"
}
```

## Workflow

If the CI/CD trigger type for an application is chosen to be GitHub trigger, this module is called by application's IaC pipeline. This module creates a GitHub trigger connected to the [source code repo][application-repo] of the application.

<!-- LINKS: https://www.markdownguide.org/basic-syntax/#reference-style-links -->

<!-- END_TF_DOCS -->
[application-repo]: ../../../app-factory-template/README.md?plain=1#L63
