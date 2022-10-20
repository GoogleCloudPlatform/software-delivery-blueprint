<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 4.3.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.28.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.31.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 4.31.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_repo"></a> [acm\_repo](#input\_acm\_repo) | ACM repo name. | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment. | `string` | n/a | yes |
| <a name="input_git_email"></a> [git\_email](#input\_git\_email) | GitHub user email. | `string` | n/a | yes |
| <a name="input_git_org"></a> [git\_org](#input\_git\_org) | GitHub org. | `string` | n/a | yes |
| <a name="input_git_user"></a> [git\_user](#input\_git\_user) | GitHub user. | `string` | n/a | yes |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | GitHub access token | `string` | n/a | yes |
| <a name="input_gke_cluster_id"></a> [gke\_cluster\_id](#input\_gke\_cluster\_id) | GKE cluster id. | `string` | n/a | yes |
| <a name="input_gke_cluster_name"></a> [gke\_cluster\_name](#input\_gke\_cluster\_name) | GKE cluster name. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GKE cluster name. | `string` | n/a | yes |

## Usage
```hcl
module "acm" {
source                = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//acm/"
gke_cluster_id        = <GKE Cluster ID>
gke_cluster_name      = <GKE Cluster Name>
env                   = "dev"
project_id            = <Project ID of GKE>
git_user              = "abc"
git_email             = "abc@github.com"
git_org               = <GitHub org>
github_token          = <GitHub access token>
acm_repo              = "my-acm-repo"
}
```

## Workflow
This module is called from [multi-tenant platform repo][muti-tenant-platform-repo] that stands up multi-tenant infrastructure for [dev][dev-multi-tenant], [staging][staging-multi-tenant] and [prod][prod-multi-tenant] environments.
The module creates hub membership for GKE clusters, sets up connection between GKE clusters and ACM repo and then hydrate ACM repo with cluster config and cluster selector files.

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
[dev-multi-tenant]: ../../platform-template/env/dev/main.tf?plain=1#L89
[staging-multi-tenant]: ../../platform-template/env/staging/main.tf?plain=1#L89
[prod-multi-tenant]: ../../platform-template/env/prod/main.tf?plain=1#L89
