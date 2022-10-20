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
| <a name="provider_null"></a> [null](#provider\_null) | ~> 2.1 |

## Inputs

| Name | Description                                          | Type | Default | Required |
|------|------------------------------------------------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | GKE cluster name.                                    | `string` | n/a | yes |
| <a name="input_cluster_path"></a> [cluster\_path](#input\_cluster\_path) | GKE cluster path.                                    | `string` | n/a | yes |
| <a name="input_git_email"></a> [git\_email](#input\_git\_email) | GitHub user email.                                   | `string` | n/a | yes |
| <a name="input_git_org"></a> [git\_org](#input\_git\_org) | GitHub org.                                          | `string` | n/a | yes |
| <a name="input_git_repo"></a> [git\_repo](#input\_git\_repo) | GitHub repo name.                                    | `string` | n/a | yes |
| <a name="input_git_user"></a> [git\_user](#input\_git\_user) | GitHub user.                                         | `string` | n/a | yes |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | GitHub access token.                                 | `string` | n/a | yes |
| <a name="input_require_approval"></a> [require\_approval](#input\_require\_approval) | Approval flag that permits deployment in the target. | `bool` | `false` | no |

## Usage

```hcl
module "cloud-deploy-target-render" {
  source                = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//cloud-deploy-targets/render"
  git_user              = <GitHub user>
  git_email             = <GitHub user email>
  git_org               = <GitHub org>
  github_token          = <GitHub access token>
  git_repo              = "terraform-modules"
  cluster_name          = <Target GKE Cluster name>
  cluster_path          = <Target GKE Cluster path>
  require_approval      = "false"
}
```

## Workflow

This module is called from [multi-tenant platform repo][muti-tenant-platform-repo] that stands up multi-tenant infrastructure for [dev][dev-multi-tenant], [staging][staging-multi-tenant] and [prod][prod-multi-tenant] environments.
The module follows the [rendering pattern][rendering-pattern] and creates a Terraform file for each GKE cluster in [cloud-deploy-targets][cloud-deploy-targets] module.

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
[muti-tenant-platform-repo]: ../../../platform-template
[dev-multi-tenant]: ../../../platform-template/env/dev/main.tf?plain=1#L113
[staging-multi-tenant]: ../../../platform-template/env/staging/main.tf?plain=1#L113
[prod-multi-tenant]: ../../../platform-template/env/prod/main.tf?plain=1#L113
[cloud-deploy-targets]: ../../cloud-deploy-targets
[rendering-pattern]: ../../README.md/#rendering-pattern
