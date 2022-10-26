<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.28.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gcp-project"></a> [gcp-project](#module\_gcp-project) | terraform-google-modules/project-factory/google | 13.1.0 |


## Inputs

| Name | Description                                                                                        | Type | Default | Required |
|------|----------------------------------------------------------------------------------------------------|------|---------|:--------:|
| <a name="input_addtl_apis"></a> [addtl\_apis](#input\_addtl\_apis) | List of apis to activate in addition the the core apis specified by the platform engineering team. | `list(string)` | `[]` | no |
| <a name="input_base_project_name"></a> [base\_project\_name](#input\_base\_project\_name) | Base name of the project, this will get concatenated with the env to make the full project name.   | `string` | n/a | yes |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | Id of the billing account to associate this project with.                                          | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment that this project will be used for. Example: dev, staging, prod.                       | `string` | n/a | yes |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | Id of a folder to host this project.                                                               | `string` | `""` | no |
| <a name="input_org_id"></a> [org\_id](#input\_org\_id) | GCP organization ID.                                                                               | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project"></a> [project](#output\_project) | Object containing details of the GCP project. |

## Usage

```hcl
module "create-gcp-project" {
  source = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//project/"
  base_project_name = "my-project"
  billing_account = 1111-2222-3333-4444
  org_id = <GCP Org>
  folder_id = ""
  env = "dev"
  addtl_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "cloudbuild.googleapis.com",
    "containerregistry.googleapis.com",
    "gkehub.googleapis.com",
    "anthosconfigmanagement.googleapis.com"]
}
```

## Workflow

This module is called from [multi-tenant platform repo][muti-tenant-platform-repo] that stands up multi-tenant infrastructure for [dev][dev-multi-tenant], [staging][staging-multi-tenant] and [prod][prod-multi-tenant] environments to create a GCP project. Additionally, this module can be called by [infrastructure repo][infra-repo] if the application needs its own projects.

<!-- LINKS: https://www.markdownguide.org/basic-syntax/#reference-style-links -->

<!-- END_TF_DOCS -->

[muti-tenant-platform-repo]: ../../platform-template
[dev-multi-tenant]: ../../platform-template/env/dev/main.tf?plain=1#L34
[staging-multi-tenant]: ../../platform-template/env/staging/main.tf?plain=1#L34
[prod-multi-tenant]: ../../platform-template/env/prod/main.tf?plain=1#L34
[infra-repo]: ../../app-factory-template/README.md?plain=1#L64
