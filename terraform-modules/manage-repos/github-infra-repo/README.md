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

| Name | Description                                                           | Type | Default | Required |
|------|-----------------------------------------------------------------------|------|---------|:--------:|
| <a name="input_app_runtime"></a> [app\_runtime](#input\_app\_runtime) | Type of runtime for the application e.g java or golang or python etc. | `string` | n/a | yes |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application which will also be the name of the repo.      | `string` | n/a | yes |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | GCP billing account.                                                  | `string` | n/a | yes |
| <a name="input_cd_sa"></a> [cd\_sa](#input\_cd\_sa) | Cloud Deploy CICD SA.                                                 | `string` | n/a | yes |
| <a name="input_ci_sa"></a> [ci\_sa](#input\_ci\_sa) | Cloud Build CICD SA.                                                  | `string` | n/a | yes |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | GCP folder ID under which you are creating the application.           | `string` | `""` | no |
| <a name="input_github_email"></a> [github\_email](#input\_github\_email) | GitHub user email.                                                    | `string` | n/a | yes |
| <a name="input_github_user"></a> [github\_user](#input\_github\_user) | GitHub username.                                                      | `string` | n/a | yes |
| <a name="input_org_id"></a> [org\_id](#input\_org\_id) | GCP org id.                                                           | `string` | n/a | yes |
| <a name="input_org_name_to_clone_template_from"></a> [org\_name\_to\_clone\_template\_from](#input\_org\_name\_to\_clone\_template\_from) | GitHub org where the repo will be created.                            | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Id of the application admin/seed project.                             | `string` | n/a | yes |
| <a name="input_project_number"></a> [project\_number](#input\_project\_number) | Project number of the application admin/seed project.                 | `number` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region where the application related resources will be created.       | `string` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | CICD Cloud Build IaC.                                                 | `string` | n/a | yes |
| <a name="input_state_bucket"></a> [state\_bucket](#input\_state\_bucket) | Terraform state bucket for the IaC.                                   | `string` | n/a | yes |
| <a name="input_trigger_type"></a> [trigger\_type](#input\_trigger\_type) | webhook to github trigger.                                            | `string` | `"webhook"` | no |

## Usage

```hcl
module "setup-iac-pipeline" {
  source = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//manage-repos/github-infra-repo"
  application_name = "my-app"
  org_name_to_clone_template_from = "YOUR_GITHUB_ORG"
  trigger_type = "webhook"
  project_number = 123456789
  project_id = <Project Id>
  service_account = <SA for IaC Cloud Build pipeline>
  app_runtime = "java"
  github_user = <GitHub user>
  github_email = <GitHub user email>
  org_id = <GCP Org>
  billing_account = "1111-2222-3333-4444"
  state_bucket = <TF state bucket>
  ci_sa  = <SA for CI Cloud Build pipeline>
  cd_sa = <SA for Cloud deploy>
  region = "us-central1"
  folder_id = "" 
}
```

## Workflow

This module is called from _app-name_.tf files in [Application Factory][application-factory] repo for each application and performs the following actions:

-   sets up [infrastructure repo][infra-repo] for the application.
-   optionally creates a webhook or GitHub trigger connected to the infrastructure repo.

<!-- LINKS: https://www.markdownguide.org/basic-syntax/#reference-style-links -->

<!-- END_TF_DOCS -->

[application-factory]: ../../../app-factory-template/README.md
[infra-repo]: ../../../app-factory-template/README.md?plain=1#L64
