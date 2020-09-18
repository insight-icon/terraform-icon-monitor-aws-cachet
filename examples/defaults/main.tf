provider "aws" {
  region = var.region
}

variable "region" {
  default = "us-east-1"
}

variable "username" {
  default = "cachet"
}
variable "password" {
  default = "hunter21"
}
variable "public_key_key" {}
variable "private_key_path" {}

module "network" {
  source = "github.com/insight-icon/terraform-icon-monitor-aws-network.git?ref=master"
}

module "rds" {
  source         = "github.com/insight-icon/terraform-icon-monitor-aws-rds.git?ref=master"
  security_group = module.network.rds_security_group_id
  subnet_ids     = module.network.public_subnets
  username       = var.username
  password       = var.password
}

output "endpoint" {
  value = module.rds.this_db_instance_endpoint
}

module "defaults" {
  source      = "../.."
  db_host     = module.rds.this_db_instance_endpoint
  db_password = var.password
  db_username = var.username

  private_key_path  = var.private_key_path
  public_key        = var.public_key_key
  security_group_id = module.network.cachet_security_group_id
  subnet_id         = module.network.public_subnets[0]

  root_domain_name = "blockstatus.net"
  hostname         = "ci"
}
