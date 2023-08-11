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
| <a name="provider_null"></a> [null](#provider\_null) | ~> 2.1 |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | GKE cluster name. | `string` | n/a | yes |
| <a name="input_cluster_project_id"></a> [cluster\_project\_id](#input\_cluster\_project\_id) | Id of the project containing GKE cluster. | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment. | `string` | n/a | yes |
| <a name="input_git_email"></a> [git\_email](#input\_git\_email) | GitHub user email. | `string` | n/a | yes |
| <a name="input_git_org"></a> [git\_org](#input\_git\_org) | GitHub organization. | `string` | n/a | yes |
| <a name="input_git_user"></a> [git\_user](#input\_git\_user) | GitHub user. | `string` | n/a | yes |
| <a name="input_index"></a> [index](#input\_index) | Arbitrary number to handle race condition of locking the git files. | `number` | n/a | yes |
| <a name="input_tf_modules_repo"></a> [tf\_modules\_repo](#input\_tf\_modules\_repo) | Terraform module repo. | `string` | n/a | yes |

## Usage

```hcl
module "landing-zone-render" {
  source                = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//landing-zone/render"
  git_user              = <GitHub user>
  git_email             = <GitHub user email>
  git_org               = <GitHub org>
  tf_modules_repo       = "terraform-modules"
  cluster_name          = "my-cluster"
  cluster_project_id    = <Clutser project id>
  env                   = "dev"
  index                 = 0
}
```

## Workflow

This module is called from [multi-tenant platform repo][muti-tenant-platform-repo] that stands up multi-tenant infrastructure for [dev][dev-multi-tenant], [staging][staging-multi-tenant] and [prod][prod-multi-tenant] environments.
The module follows the [rendering pattern][rendering-pattern] and creates Terraform files for each GKE cluster under [landing-zone][landing-zone] module. These files contain Terraform code to create landing zone on respective cluster.

<!-- LINKS: https://www.markdownguide.org/basic-syntax/#reference-style-links -->

<!-- END_TF_DOCS -->
[muti-tenant-platform-repo]: ../../../platform-template
[dev-multi-tenant]: ../../../platform-template/env/dev/main.tf?plain=1#L127
[staging-multi-tenant]: ../../../platform-template/env/staging/main.tf?plain=1#L127
[prod-multi-tenant]: ../../../platform-template/env/prod/main.tf?plain=1#L127
[landing-zone]: ../../landing-zone
[rendering-pattern]: ../../README.md/#rendering-pattern
