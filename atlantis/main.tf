module "vpc" {
  source                  = "../modules/vpc"
  vpc_name                = "atlantis_vpc"
  private_subnet_name     = "atlantis_subnet"
  igw_name                = "atlantis_igw"
  vpc_cidr                = "10.1.0.0/16"
  cidr_private_subnet     = "10.1.10.0/24"
  map_public_ip_on_launch = true
}

module "security_group" {
  source         = "../modules/security_group"
  sg_vpc_id      = module.vpc.vpc_id
  sg_name        = "atlantis_sg"
  sg_description = "SSH traffic and 4141 to atlantis"
}

module "security_group_rule-4141" {
  source            = "../modules/security_group_rules"
  sg_rule_id        = module.security_group.security_group_id
  sg_rule_type      = "ingress"
  sg_from_rule_port = "4141"
  sg_to_rule_port   = "4141"
  sg_rule_protocol  = "tcp"
}

module "security_group_rule-22" {
  source              = "../modules/security_group_rules"
  sg_rule_id          = module.security_group.security_group_id
  sg_rule_type        = "ingress"
  sg_from_rule_port   = "22"
  sg_to_rule_port     = "22"
  sg_rule_protocol    = "tcp"
  sg_rule_cidr_blocks = ["201.69.232.217/32"]
}

module "security_group_rule-output" {
  source            = "../modules/security_group_rules"
  sg_rule_id        = module.security_group.security_group_id
  sg_rule_type      = "egress"
  sg_from_rule_port = "0"
  sg_to_rule_port   = "65535"
  sg_rule_protocol  = "-1"
}

module "ec2_atlantis" {
  source                      = "../modules/ec2"
  region                      = var.region_subnet
  ami_id                      = "ami-09d56f8956ab235b3"
  prefix                      = "atlantis_server"
  servers                     = 1
  subnet_id                   = module.vpc.subnet_id
  security_group_id           = module.security_group.security_group_id
  associate_public_ip_address = true
  user_data                   = "../scripts/atlantis.sh"
}