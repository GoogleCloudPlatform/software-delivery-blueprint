## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.28.0 |


## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.28.0 |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_factory_project"></a> [app\_factory\_project](#input\_app\_factory\_project) | Project Number of Application Factory. | `number` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment. | `string` | n/a | yes |
| <a name="input_function_gcs"></a> [function\_gcs](#input\_function\_gcs) | GCS bucket to store function code. | `string` | n/a | yes |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name of the cloud function. | `string` | n/a | yes |
| <a name="input_infra_project_id"></a> [infra\_project\_id](#input\_infra\_project\_id) | Project Id of the platform admin project. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project Id where the function will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region. | `string` | n/a | yes |
| <a name="input_secrets_project_id"></a> [secrets\_project\_id](#input\_secrets\_project\_id) | Project ID of the project hosting the secrets. | `string` | n/a | yes |
| <a name="input_trigger_gcs"></a> [trigger\_gcs](#input\_trigger\_gcs) | GCS bucket to trigger function on addition of an object. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_gcs"></a> [function\_gcs](#output\_function\_gcs) | URL of the bucket hosting cloud function's code. |
| <a name="output_function_id"></a> [function\_id](#output\_function\_id) | Id of the function. |
| <a name="output_trigger_gcs"></a> [trigger\_gcs](#output\_trigger\_gcs) | URL of the bucket that triggers the cloud function. |

## Usage
```hcl
module "deploy-cloud-function" {
  source                = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//cloud-functions/grant-deploy-access"
  project_id            = var.project_id
  function_name         = var.function_name
  function_gcs          = var.function_gcs
  trigger_gcs           = var.trigger_gcs
  region                = var.region
  app_factory_project   = var.app_factory_project_num
  secrets_project_id    = var.secrets_project_id
  infra_project_id      = var.project_id
  env                   = var.env
}
```

## Workflow
This module is called from [multi-tenant platform repo][muti-tenant-platform-repo] that stands up multi-tenant infrastructure for [dev][dev-multi-tenant], [staging][staging-multi-tenant] and [prod][prod-multi-tenant] environments.
This module creates a [Cloud Function][cloud-function] and two [Cloud Storage][cloud-storage] buckets, one for storing the function's code and the other to trigger the function when an object is added to it.

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
[common-setup]: ../../../common-setup
[cloud-function]: https://cloud.google.com/functions
[cloud-storage]: https://cloud.google.com/storage
[muti-tenant-platform-repo]: ../../platform-template
[dev-multi-tenant]: ../../platform-template/env/dev/main.tf?plain=1#L89
[staging-multi-tenant]: ../../platform-template/env/staging/main.tf?plain=1#L89
[prod-multi-tenant]: ../../platform-template/env/prod/main.tf?plain=1#L89
<!-- END_TF_DOCS -->