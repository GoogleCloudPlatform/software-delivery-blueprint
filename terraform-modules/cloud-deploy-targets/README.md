<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.28.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Region of the target. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project to create the target in. | `string` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | Google service account to use for execution. | `string` | n/a | yes |

## Usage

```hcl
module "cloud-deploy-targets" {
  source = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules//cloud-deploy-targets"
  service_account = <SA that will be used to deploy to the target>
  project         = <Project Id where the target will be created>
  location        = "us-central1"
}
```

## Workflow

Pre-requisite : The [Cloud Deploy targets render module][cloud-deploy-targets-render] adds a Terraform file for each GKE cluster in this module when multi-tenant infrastructure is created.

This module is called from _app-name_.tf files in [Application Factory][application-factory] repo for each application and creates Google Cloud Deploy target for each GKE cluster.

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
[cloud-deploy-targets-render]: render
