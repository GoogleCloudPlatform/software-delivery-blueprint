<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.28.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 4.31.0 |


## Inputs

| Name | Description                                                     | Type | Default | Required |
|------|-----------------------------------------------------------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description of the Artifact registry.                           | `string` | n/a | yes |
| <a name="input_format"></a> [format](#input\_format) | Format of the Artifact registry.                                | `string` | `"DOCKER"` | no |
| <a name="input_id"></a> [id](#input\_id) | Id of the Artifact registry.                                    | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Region of the Artifact registry.                                | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Id of the project where the artifact registry is being created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_registry"></a> [registry](#output\_registry) | The name of the Artifact Registry. |

## Usage

```hcl
module "artifact-registry" {
  source = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules//artifact-registry"
  id          = <Registry name>
  project_id  = "my-app"
  location    = us-central1
  description = "Artifact registry for my-app"
}
```
## Workflow

Pre-requisite : The [Artifact Regitry render module][artifact-registry-render] adds a Terraform file for each GKE cluster in this module when multi-tenant infrastructure is created. 

This module is called from _app-name_.tf files in [Application Factory][application-factory] repo for each application and performs the following actions:
- creates an Artifact Registry repo in Docker format.
- permissions service account for each GKE cluster to access the Artifact Registry repo created in the above step.

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
[artifact-registry-render]: render
