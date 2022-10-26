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

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | GKE cluster name. | `string` | n/a | yes |
| <a name="input_git_email"></a> [git\_email](#input\_git\_email) | GitHub user email. | `string` | n/a | yes |
| <a name="input_git_org"></a> [git\_org](#input\_git\_org) | GitHub org. | `string` | n/a | yes |
| <a name="input_git_repo"></a> [git\_repo](#input\_git\_repo) | GitHub repo name. | `string` | n/a | yes |
| <a name="input_git_user"></a> [git\_user](#input\_git\_user) | GitHub user. | `string` | n/a | yes |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | GitHub access token. | `string` | n/a | yes |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | GKE Service account that will be given permissions to access the Artifact Registry repo. | `string` | n/a | yes |

## Usage

```hcl
module "artifact-registry-render" {
  source                = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//artifact-registry/render"
  git_user              = <GitHub user>
  git_email             = <GitHub use email>
  git_org               = <GitHub org>
  github_token          = <GitHub access token>
  git_repo              = "terraform-modules"
  cluster_name          = <GKE cluster name>
  service_account_name  = <GKE Service Account>
}

```

## Workflow

This module is called from [multi-tenant platform repo][muti-tenant-platform-repo] that stands up multi-tenant infrastructure for [dev][dev-multi-tenant], [staging][staging-multi-tenant] and [prod][prod-multi-tenant] environments.
The module follows the [rendering pattern][rendering-pattern] and creates a Terraform file for each GKE cluster in [artifact-registry][artifact-registry] module.

<!-- LINKS: https://www.markdownguide.org/basic-syntax/#reference-style-links -->
<!-- END_TF_DOCS -->
[muti-tenant-platform-repo]: ../../../platform-template
[dev-multi-tenant]: ../../../platform-template/env/dev/main.tf?plain=1#L102
[staging-multi-tenant]: ../../../platform-template/env/staging/main.tf?plain=1#L102
[prod-multi-tenant]: ../../../platform-template/env/prod/main.tf?plain=1#L102
[artifact-registry]: ../../artifact-registry
[rendering-pattern]: ../../README.md/#rendering-pattern
