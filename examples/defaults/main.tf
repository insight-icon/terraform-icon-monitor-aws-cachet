
module "vpc" {
  source = "github.com/insight-icon/terraform-icon-monitor-aws-network.git?ref=master"
}

module "rds" {
  source         = "github.com/insight-icon/terraform-icon-monitor-aws-rds.git?ref=master"
  security_group = module.vpc.rds_security_group_id
  subnet_ids     = module.vpc.public_subnets
}

module "defaults" {
  source            = "../.."
  db_host           = ""
  db_password       = ""
  db_username       = ""
  private_key_path  = ""
  public_key        = ""
  security_group_id = ""
  subnet_id         = ""
}
