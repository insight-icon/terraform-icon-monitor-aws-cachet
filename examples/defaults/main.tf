
module "network" {
  source = "github.com/insight-icon/terraform-icon-monitor-aws-network.git?ref=master"
}

module "rds" {
  source         = "github.com/insight-icon/terraform-icon-monitor-aws-rds.git?ref=master"
  security_group = module.network.rds_security_group_id
  subnet_ids     = module.network.public_subnets
  username       = "cachet"
  password       = "hunter2"
}

variable "public_key" {}
variable "private_key_path" {}

output "endpoint" {
  value = module.rds.this_db_instance_endpoint
}

module "defaults" {
  source      = "../.."
  db_host     = module.rds.this_db_instance_endpoint
  db_password = "hunter21"
  db_username = "cachet"

  private_key_path  = var.private_key_path
  public_key        = var.public_key
  security_group_id = module.network.cachet_security_group_id
  subnet_id         = module.network.public_subnets[0]

  root_domain_name = "blockstatus.net"
  hostname         = "ci"
}
