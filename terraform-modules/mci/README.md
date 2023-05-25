<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.28.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.31.0 |


## Providers

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.28.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 4.31.0 |

## Inputs

| Name                                                                  | Description          | Type | Default | Required |
|-----------------------------------------------------------------------|----------------------|------|---------|:--------:|
| <a name="membership_id"></a> [membership\_id](#input\_membership\_id) | Fleet membership id. | `string` | n/a | yes |
| <a name="project_id"></a> [project\_id](#input\_project\_id)          | GCP project id.      | `string` | n/a | yes |

## Usage
```hcl
module "mci" {
  source                = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//mci/"
  membership_id         = module.acm-1.membership_id
  project_id            = module.create-gcp-project.project.project_id
}
```

## Workflow
This module is called from [multi-tenant platform repo][muti-tenant-platform-repo] that stands up multi-tenant infrastructure for  [prod][prod-multi-tenant] environment.
The module enables multi-cluster ingress and multi-cluster service on the GKE cluster.

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

[muti-tenant-platform-repo]: ../../platform-template
[prod-multi-tenant]: ../../platform-template/env/prod/main.tf?plain=1#L89
