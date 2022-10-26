<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 4.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | >= 4.3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_repositories"></a> [admin\_repositories](#input\_admin\_repositories) | (Optional) A list of repository names the current team should get admin (full) permission to. | `set(string)` | `[]` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) A description of the team. | `string` | `""` | no |
| <a name="input_maintain_repositories"></a> [maintain\_repositories](#input\_maintain\_repositories) | (Optional) A list of repository names the current team should get push (maintain) permission to. | `set(string)` | `[]` | no |
| <a name="input_maintainers"></a> [maintainers](#input\_maintainers) | (Optional) A list of users that will be added to the current team with maintainer permissions. | `set(string)` | `[]` | no |
| <a name="input_members"></a> [members](#input\_members) | (Optional) A list of users that will be added to the current team with member permissions. | `set(string)` | `[]` | no |
| <a name="input_module_depends_on"></a> [module\_depends\_on](#input\_module\_depends\_on) | (Optional) A list of external resources the module depends\_on. Default is []. | `any` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the team. | `string` | n/a | yes |
| <a name="input_parent_team_id"></a> [parent\_team\_id](#input\_parent\_team\_id) | (Optional) The ID of the parent team, if this is a nested team. | `number` | `null` | no |
| <a name="input_privacy"></a> [privacy](#input\_privacy) | (Optional) The level of privacy for the team. Must be one of secret or closed. | `string` | `"closed"` | no |
| <a name="input_pull_repositories"></a> [pull\_repositories](#input\_pull\_repositories) | (Optional) A list of repository names the current team should get pull (read-only) permission to. | `set(string)` | `[]` | no |
| <a name="input_push_repositories"></a> [push\_repositories](#input\_push\_repositories) | (Optional) A list of repository names the current team should get push (read-write) permission to. | `set(string)` | `[]` | no |
| <a name="input_triage_repositories"></a> [triage\_repositories](#input\_triage\_repositories) | (Optional) A list of repository names the current team should get push (triage) permission to. | `set(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the team. |
| <a name="output_slug"></a> [slug](#output\_slug) | The Slug of the team. |
| <a name="output_team_name"></a> [team\_name](#output\_team\_name) | The name of the team. |

## Usage

```hcl
module "engineering" {
  source = "git::https://github.com/YOUR_GITHUB_ORG/terraform-modules.git//manage-teams"
  name = "engineering"
  description = ""
  privacy = "closed"
  parent_team_id = <Parent team id>
  members = ["user1","user2"]
  maintainers = ["user1"]
  admin_repositories = ["repo1"]
  maintain_repositories = ["repo2"]
  push_repositories = ["repo1"]
  triage_repositories = ["repo1"]
  pull_repositories = ["repo2"]
}
```

## Workflow

This module is called from _team-name_.tf files in [Application Factory][application-factory] repo and creates a GitHub team.

<!-- LINKS: https://www.markdownguide.org/basic-syntax/#reference-style-links -->

<!-- END_TF_DOCS -->
[application-factory]: ../../app-factory-template/README.md
