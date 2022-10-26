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
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.28.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 2.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_repo"></a> [acm\_repo](#input\_acm\_repo) | ACM repository. | `string` | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Name of the application. | `string` | n/a | yes |
| <a name="input_cicd_sa"></a> [cicd\_sa](#input\_cicd\_sa) | CICD service account for the application. | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Environment. | `string` | n/a | yes |
| <a name="input_git_email"></a> [git\_email](#input\_git\_email) | GitHub user email. | `string` | n/a | yes |
| <a name="input_git_org"></a> [git\_org](#input\_git\_org) | GitHub organization. | `string` | n/a | yes |
| <a name="input_git_token"></a> [git\_token](#input\_git\_token) | GitHub token. | `string` | n/a | yes |
| <a name="input_git_user"></a> [git\_user](#input\_git\_user) | GitHub user. | `string` | n/a | yes |
| <a name="input_gke_project_id"></a> [gke\_project\_id](#input\_gke\_project\_id) | Id of the GKE cluster project. | `string` | n/a | yes |
| <a name="input_gsa"></a> [gsa](#input\_gsa) | Google service account. | `string` | n/a | yes |
| <a name="input_ksa"></a> [ksa](#input\_ksa) | Kubernetes service account. | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | K8s namespace for the app. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Id of the application admin project. | `string` | n/a | yes |

## Usage

```hcl
module "workload-identity" {
  source           = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//landing-zone/workload-identity"
  gsa              = "google-service-account"
  gke_project_id   = <GKE Project Id>
  app_name         = "my-app"
  ksa              = "k8s-service-account"
  cicd_sa          = "cicd-service-account"
  env              = "dev"
  project_id       = <Project Id>
  namespace        = "test"
  git_user         = <GitHub user>
  git_email        = <GitHub user email>
  git_org          = <GitHub org>
  acm_repo         = "my-acm-repo"
  git_token        = <GitHub access token>
}
```

<!-- LINKS: https://www.markdownguide.org/basic-syntax/#reference-style-links -->

<!-- END_TF_DOCS -->

[application-factory]: ../../app-factory-template/README.md
[landing-zone-render]: ../render
