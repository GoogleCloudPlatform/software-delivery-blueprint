<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.28.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.31.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gke"></a> [gke](#module\_gke) | ../beta-private-cluster


## Inputs

| Name | Description                                                      | Type | Default | Required |
|------|------------------------------------------------------------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | Environment.                                                     | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Id of the project where GKE cluster is to be created.            | `string` | n/a | yes |
| <a name="input_project_number"></a> [project\_number](#input\_project\_number) | Project number where GKE cluster is to be created.               | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | Subnet details for the GKE cluster coming from project module.   | <pre>object({<br>    description              = string<br>    gateway_address          = string<br>    id                       = string<br>    ip_cidr_range            = string<br>    name                     = string<br>    network                  = string<br>    private_ip_google_access = string<br>    project                  = string<br>    region                   = string<br>    secondary_ip_range = list(object({<br>      ip_cidr_range = string<br>      range_name    = string<br>    }))<br>    self_link = string<br>  })</pre> | n/a | yes |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | Arbitrary number to chose subnet1 or subnet2 for the GKE cluster | `number` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | List zones to create GKE cluster in.                             | `list` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Object containing GKE cluster details. |

## Usage

```hcl
module "create_gke" {
  source            = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//gke/"
  subnet            = "my-subnet-object"
  project_id        = <Project id>
  suffix            = "1"
  zone              = ["a","b","c"]
  env               = "dev"
  project_number    = "123456789"
}
```

## Workflow

This module is called from [multi-tenant platform repo][muti-tenant-platform-repo] that stands up multi-tenant infrastructure for [dev][dev-multi-tenant], [staging][staging-multi-tenant] and [prod][prod-multi-tenant] environments to create GKE cluster.

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
[dev-multi-tenant]: ../../platform-template/env/dev/main.tf?plain=1#L78
[staging-multi-tenant]: ../../platform-template/env/staging/main.tf?plain=1#L78
[prod-multi-tenant]: ../../platform-template/env/prod/main.tf?plain=1#L78
