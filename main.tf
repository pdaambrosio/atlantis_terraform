module "vpc" {
  source               = "./modules/vpc"
  vpc_name             = "webapp_vpc"
  private_subnet_name  = "webapp_subnet"
  igw_name             = "webapp_igw"
  enable_dns_support   = true
  enable_dns_hostnames = false
}

module "security_group" {
  source         = "./modules/security_group"
  sg_vpc_id      = module.vpc.vpc_id
  sg_name        = "webapp_sg"
  sg_description = "HTTP, HTTPS and SSH traffic to webapp"
}

module "security_group_rule-80" {
  source            = "./modules/security_group_rules"
  sg_rule_id        = module.security_group.security_group_id
  sg_rule_type      = "ingress"
  sg_from_rule_port = "80"
  sg_to_rule_port   = "80"
  sg_rule_protocol  = "tcp"
}

module "security_group_rule-22" {
  source              = "./modules/security_group_rules"
  sg_rule_id          = module.security_group.security_group_id
  sg_rule_type        = "ingress"
  sg_from_rule_port   = "22"
  sg_to_rule_port     = "22"
  sg_rule_protocol    = "tcp"
  sg_rule_cidr_blocks = ["201.8.154.210/32"]
}

module "security_group_rule-output" {
  source            = "./modules/security_group_rules"
  sg_rule_id        = module.security_group.security_group_id
  sg_rule_type      = "egress"
  sg_from_rule_port = "0"
  sg_to_rule_port   = "65535"
  sg_rule_protocol  = "-1"
}

module "ec2" {
  source                      = "./modules/ec2"
  prefix                      = "webapp"
  servers                     = 2
  ami_id                      = ""
  region                      = var.region_subnet
  subnet_id                   = module.vpc.subnet_id
  security_group_id           = module.security_group.security_group_id
  associate_public_ip_address = true
  user_data                   = "./scripts/user_data.sh"
}

module "elastic_load_balance" {
  source              = "./modules/elastic_load_balance"
  prefix              = "webapp"
  lb_internal         = false
  type_loadbalancer   = "network"
  subnet_id           = module.vpc.subnet_id
  tg_port             = 80
  tg_protocol         = "TCP"
  tg_vpc_id           = module.vpc.vpc_id
  listerner_port      = 80
  listener_protocol   = "TCP"
  listerner_type      = "forward"
  tg_number_instances = 2
  tg_instances_id     = module.ec2.instances_id
  tg_instances_port   = 80
}

module "elastic_block_storage" {
  source                = "./modules/elastic_block_storage"
  ebs_availability_zone = module.ec2.availability_zone[0]
  ebs_size              = 8
  ebs_type              = "gp2"
  ebs_iops              = 0
  ebs_device_name       = "/dev/sdh"
  ebs_instance_id       = module.ec2.instances_id[0]
}