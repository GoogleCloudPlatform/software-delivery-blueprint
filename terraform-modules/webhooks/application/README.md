<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 4.3.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.28.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 2.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | >= 4.3.0 |
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.28.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 2.2 |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Name of the application for which the trigger is being created | `string` | n/a | yes |
| <a name="input_app_repo_name"></a> [app\_repo\_name](#input\_app\_repo\_name) | Name of the app repo. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Id of the application admin project. | `string` | n/a | yes |
| <a name="input_project_number"></a> [project\_number](#input\_project\_number) | Project number of the application admin project. | `number` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | Service Account to associate Cloud Build trigger with. | `string` | n/a | yes |

## Usage

```hcl
module "web-hook" {
  source = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules//webhooks/application"
  app_name        = "my-app"
  project_number  = 123456789
  app_repo_name   = "my-app"
  project_id      = <Project Id>
  service_account = <Service Account>
}
```

## Workflow

If the CI/CD trigger type for an application is chosen to be webhook trigger, this module is called by application's IaC pipeline. This module creates a webhook trigger connected to the [source code repo][application-repo] of the application.

<!-- LINKS: https://www.markdownguide.org/basic-syntax/#reference-style-links -->

<!-- END_TF_DOCS -->
[application-repo]: ../../../app-factory-template/README.md?plain=1#L63
