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

| Name | Description                                                             | Type | Default | Required |
|------|-------------------------------------------------------------------------|------|---------|:--------:|
| <a name="input_cluster"></a> [cluster](#input\_cluster) | GKE cluster name.                                                       | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | GCP region.                                                             | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Cloud Deploy target.                                        | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Id of the project where the Cloud Deploy target is to be created.       | `string` | n/a | yes |
| <a name="input_require_approval"></a> [require\_approval](#input\_require\_approval) | Approval flag that permits deployment in the target.                    | `bool` | `false` | no |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | Service Account that will be used to deploy to the Cloud Deploy target. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_target"></a> [target](#output\_target) | The full Cloud Deploy target object. |

## Usage

```hcl
module "cloud-deploy-target" {
  source           = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//cloud-deploy-targets/target"
  name             = "my-gke-cluster"
  cluster          = "full-gke-cluster-path"
  require_approval = false
  location         = "us-central1"
  project          = <Project Id>
  service_account  = <Service account>
}
```

<!-- LINKS: https://www.markdownguide.org/basic-syntax/#reference-style-links -->
<!-- END_TF_DOCS -->
