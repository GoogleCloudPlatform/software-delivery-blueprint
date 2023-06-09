<!-- BEGIN_TF_DOCS -->
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
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Application name. | `string` | n/a | yes |
| <a name="input_cb_iac_service_account"></a> [cb\_iac\_service\_account](#input\_cb\_iac\_service\_account) | Cloud Build SA for IaC pipeline. | `string` | n/a | yes |
| <a name="input_infra_project_id"></a> [infra\_project\_id](#input\_infra\_project\_id) | Id of the multi-tenant infrastructure project. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Google Cloud region. | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | The list of all the secrets required to be copied from application factory to application admin project. | `list(string)` | n/a | yes |
| <a name="input_seed_project_id"></a> [seed\_project\_id](#input\_seed\_project\_id) | Id of the application admin project. | `string` | n/a | yes |

## Usage

```hcl
module "copy-secrets" {
source = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//app-group-copy-secrets"
secrets = ["secret1", "secret2"]
infra_project_id = <Source project id>
seed_project_id = <Destination project id>
cb_iac_service_account = <Cloud Build SA that needs to read the secrets>
app_name = "my-app"
region   = "us-central1"
}
```

## Workflow

This module is called from the _app-name_.tf files stored in the [Application Factory][application-factory] repo for each application. The module performs the following actions:
- copies a bunch of secrets from multi-tenant admin project into the application admin project.
- creates two new secrets named `app-name` and `env-repo` in the application admin project.

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
