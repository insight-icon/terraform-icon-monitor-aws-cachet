resource "random_pet" "this" {
  length = 2
}

data "aws_caller_identity" "this" {}

resource "aws_s3_bucket" "backend" {
  count  = var.create ? 1 : 0
  bucket = "logs-${data.aws_caller_identity.this.account_id}"
  acl    = "private"

  force_destroy = var.force_destroy

  tags = var.tags
}

module "ami" {
  source = "github.com/insight-infrastructure/terraform-aws-ami.git?ref=v0.1.0"
}

resource "aws_key_pair" "this" {
  public_key = file(var.public_key_path)
}

resource "aws_instance" "this" {
  count         = var.create ? 1 : 0
  ami           = module.ami.ubuntu_1804_ami_id
  instance_type = "t2.small"

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  iam_instance_profile = join("", aws_iam_instance_profile.this.*.id)
  key_name             = aws_key_pair.this.*.key_name[0]

  tags = merge({
    name = var.name
  }, var.tags)
}

module "ansible" {
  source           = "github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=v0.11.0"
  ip               = join("", aws_instance.this.*.public_ip)
  user             = "ubuntu"
  private_key_path = var.private_key_path

  playbook_file_path = "${path.module}/ansible/main.yml"
  playbook_vars = {
    local_build = var.cachet_local_build
    db_username = var.db_username
    db_password = var.db_password
    db_host     = var.db_host
    fqdn        = local.fqdn
    env_file    = var.env_file == "" ? "${path.module}/config.env.defaults" : var.env_file
  }

  requirements_file_path = "${path.module}/ansible/requirements.yml"

  module_depends_on = [join("", aws_route53_record.this.*.id)]
}

locals {
  fqdn = var.hostname != "" ? "${var.hostname}.${var.root_domain_name}" : var.root_domain_name
}

data "aws_route53_zone" "this" {
  count = var.root_domain_name != "" ? 1 : 0
  name  = "${var.root_domain_name}."
}

resource "aws_route53_record" "this" {
  count = var.root_domain_name != "" ? 1 : 0

  zone_id = join("", data.aws_route53_zone.this.*.zone_id)

  name    = local.fqdn
  type    = "A"
  ttl     = "300"
  records = [join("", aws_instance.this.*.public_ip)]
}

resource "aws_route53_record" "www" {
  count = var.root_domain_name != "" ? 1 : 0

  zone_id = join("", data.aws_route53_zone.this.*.zone_id)

  name    = "www.${local.fqdn}"
  type    = "A"
  ttl     = "300"
  records = [join("", aws_instance.this.*.public_ip)]
}

//resource "aws_route53_record" "www" {
//  count = var.root_domain_name != "" ? 1 : 0
//
//  zone_id = join("", data.aws_route53_zone.this.*.id)
//  name    = "www"
//  type    = "CNAME"
//  ttl     = "5"
//
//  set_identifier = "dev"
//  records        = join("", aws_route53_record.this.*.records)
//}

