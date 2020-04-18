# terraform-icon-monitor-aws-cachet

[![open-issues](https://img.shields.io/github/issues-raw/insight-icon/terraform-icon-monitor-aws-cachet?style=for-the-badge)](https://github.com/insight-icon/terraform-icon-monitor-aws-cachet/issues)
[![open-pr](https://img.shields.io/github/issues-pr-raw/insight-icon/terraform-icon-monitor-aws-cachet?style=for-the-badge)](https://github.com/insight-icon/terraform-icon-monitor-aws-cachet/pulls)

## Features

This module sets up a cachet status page on AWS / docker with Ansible.  SSL cert with letsencyrpt.  

## Terraform Versions

For Terraform v0.12.0+

## Usage

```
module "this" {
    source = "github.com/insight-icon/terraform-icon-monitor-aws-cachet"

}
```
## Examples

- [defaults](https://github.com/insight-icon/terraform-icon-monitor-aws-cachet/tree/master/examples/defaults)

## Known  Issues
No issue is creating limit on this module.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| cachet\_local\_build | Bool to install php for cachet | `bool` | `false` | no |
| create | Bool to create all | `bool` | `true` | no |
| db\_host | The host for the db | `string` | n/a | yes |
| db\_password | the db password | `string` | n/a | yes |
| db\_username | the db password | `string` | n/a | yes |
| env\_file | Path to file for cachet | `string` | `""` | no |
| environment | The environment | `string` | `""` | no |
| hostname | hostname for A record - blank to not create record at all | `string` | `""` | no |
| name | The name for the label | `string` | `"prep"` | no |
| namespace | The namespace to deploy into | `string` | `"prod"` | no |
| network\_name | The network name, ie kusama / mainnet | `string` | `"testnet"` | no |
| owner | Owner of the infrastructure | `string` | `""` | no |
| private\_key\_path | Path to the private ssh key | `string` | n/a | yes |
| public\_key | Public ssh key | `string` | n/a | yes |
| root\_domain\_name | The root domain | `string` | `""` | no |
| security\_group\_id | The sg to deploy into | `string` | n/a | yes |
| subnet\_id | The subnet id to deploy into | `string` | n/a | yes |
| vpc\_type | The type of vpc | `string` | `"monitoring"` | no |

## Outputs

| Name | Description |
|------|-------------|
| fqdn | n/a |
| private\_ip | n/a |
| public\_ip | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Testing
This module has been packaged with terratest tests

To run them:

1. Install Go
2. Run `make test-init` from the root of this repo
3. Run `make test` again from root

## Authors

Module managed by [insight-icon](https://github.com/insight-icon)

## Credits

- [Anton Babenko](https://github.com/antonbabenko)

## License

Apache 2 Licensed. See LICENSE for full details.