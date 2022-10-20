<!-- BEGIN_TF_DOCS -->
## Usage

```hcl
module "landing-zone-render" {
  source                = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//landing-zone/dev"
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

Pre-requisite : The [landing-zone-render module][landing-zone-render] adds a folder for each environment in this module and creates Terraform files for corresponding GKE cluster inside those folders when multi-tenant infrastructure is created.

This module is called from _app-name_.tf files in [Application Factory][application-factory] repo for each application and performs the following actions as part of landing zone creation for the application:

-   creates Kubernetes yaml files for namespace, Kubernetes Service Account and network-policy and commits them to ACM repo that creates these resources on the GKE clusters.
-   grants permissions to Google Service Account on Kubernetes Service Account to complete workload identity setup. 

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
[landing-zone-render]: render
[acm]: https://cloud.google.com/anthos/config-management
[acm-template]: ../../acm-template/README.md
