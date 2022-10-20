<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.28.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.28.0 |
| <a name="provider_google.impersonated"></a> [google.impersonated](#provider\_google.impersonated) | >= 4.28.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_admin-project"></a> [admin-project](#module\_admin-project) | terraform-google-modules/project-factory/google | 11.3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_factory_cb_service_account"></a> [app\_factory\_cb\_service\_account](#input\_app\_factory\_cb\_service\_account) | Cloud Build service account of application factory. | `string` | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Name of the application being created. | `string` | n/a | yes |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | Billing account identifier that will be linked to the application admin project. | `string` | n/a | yes |
| <a name="input_create_service_account"></a> [create\_service\_account](#input\_create\_service\_account) | If set to true, Terraform will create the service accounts for Cloud Build IaC and CICD and Cloud Deploy and grant required permissions to them. | `bool` | `true` | no |
| <a name="input_custom_sa"></a> [custom\_sa](#input\_custom\_sa) | Service Account that will be used to add Cloud Deploy SA to IAM group through impersonation. | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | environment list for the application. | `list` | n/a | yes |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | Google Cloud folder identifier that the application admin project will be created in. | `string` | `""` | no |
| <a name="input_group_id"></a> [group\_id](#input\_group\_id) | Google IAM Group Id. | `string` | n/a | yes |
| <a name="input_org_id"></a> [org\_id](#input\_org\_id) | Google Cloud organization identifier. | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the application admin project that should be created, this will be same as the application name. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region that the IaC bucket should reside in. | `string` | `"us-central1"` | no |

## Outputs

| Name | Description                                                                      |
|------|----------------------------------------------------------------------------------|
| <a name="output_cicd_sa_email"></a> [cicd\_sa\_email](#output\_cicd\_sa\_email) | The email for the service account created to run the CI/CD pipeline.             |
| <a name="output_cicd_sa_id"></a> [cicd\_sa\_id](#output\_cicd\_sa\_id) | The identifier for the service account created to run the CI/CD pipeline.        |
| <a name="output_clouddeploy_sa_email"></a> [clouddeploy\_sa\_email](#output\_clouddeploy\_sa\_email) | The email for the service account created to run the Cloud Deploy pipeline.      |
| <a name="output_clouddeploy_sa_id"></a> [clouddeploy\_sa\_id](#output\_clouddeploy\_sa\_id) | The identifier for the service account created to run the Cloud Deploy pipeline. |
| <a name="output_iac_bucket_name"></a> [iac\_bucket\_name](#output\_iac\_bucket\_name) | Name of the bucket that stores the IaC state files.                              |
| <a name="output_iac_sa_email"></a> [iac\_sa\_email](#output\_iac\_sa\_email) | The email for the service account created to run the IaC pipeline.               |
| <a name="output_iac_sa_id"></a> [iac\_sa\_id](#output\_iac\_sa\_id) | The identifier for the service account created to run the IaC pipeline.          |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | Project Id of the admin project.                                                 |
| <a name="output_project_number"></a> [project\_number](#output\_project\_number) | Project number of the admin project.                                             |
| <a name="output_workload_gsa"></a> [workload\_gsa](#output\_workload\_gsa) | The map containing env and the service account created for workload identity.    |

## Usage

```hcl

data "google_service_account_access_token" "default" {
  provider               = google
  target_service_account = <Custom Service Account>
  scopes                 = ["userinfo-email", "cloud-platform"]
  lifetime               = "300s"
}

provider "google" {
  alias        = "impersonated"
  access_token = data.google_service_account_access_token.default.access_token
}

module "admin-seed-project" {
  source = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//app-group-admin-seed"
  project_name = "my-app"
  billing_account = <GCP Billing Account>>
  org_id = <GCP org>
  folder_id = ""
  app_factory_cb_service_account = <Cloud Build Service Accout>
  group_id = <IAM Group ID>
  app_name = "my-app"
  custom_sa = <Custom Service Account>
  env = "dev"
  region = "us-central1"
  providers = { google.impersonated = google.impersonated }
}
```

## Workflow
This module is called from _app-name_.tf files in [Application Factory][application-factory] repo for each application. The module creates:
- an application admin project.
- service accounts and their permissions for:
  - IaC Cloud Build pipeline.
  - CI Cloud Build pipeline.
  - Cloud Deploy.
  - Workload identity.
- GCS bucket to store Terraform state in admin project.

## License

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

## Contributing

*   [Contributing guidelines][contributing-guidelines]
*   [Code of conduct][code-of-conduct]

<!-- LINKS: https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributing-guidelines]: CONTRIBUTING.md
[code-of-conduct]: code-of-conduct.md
<!-- END_TF_DOCS -->

[application-factory]: ../../app-factory-template/README.md
