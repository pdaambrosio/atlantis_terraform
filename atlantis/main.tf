data "aws_ami" "atlantis" {
  most_recent = true
  owners      = ["self"]
  name_regex  = "^atlantis-.*$"
  filter {
    name   = "tag:Environment"
    values = ["IAC"]
  }
}

module "vpc" {
  source                  = "git@github.com:pdaambrosio/module_vpc_public_subnet_aws.git"
  vpc_name                = "atlantis_vpc"
  public_subnet_name      = "atlantis_subnet"
  igw_name                = "atlantis_igw"
  vpc_cidr                = "10.1.0.0/16"
  cidr_public_subnet      = "10.1.10.0/24"
  map_public_ip_on_launch = true
}

module "security_group" {
  source         = "git@github.com:pdaambrosio/module_security_group_aws.git"
  sg_vpc_id      = module.vpc.vpc_id
  sg_name        = "atlantis_sg"
  sg_description = "SSH traffic and 4141 to atlantis"
}

module "security_group_rule-4141" {
  source            = "git@github.com:pdaambrosio/module_security_group_rules_aws.git"
  sg_rule_id        = module.security_group.security_group_id
  sg_rule_type      = "ingress"
  sg_from_rule_port = "4141"
  sg_to_rule_port   = "4141"
  sg_rule_protocol  = "tcp"
  sg_rule_cidr_blocks = ["0.0.0.0/0"]
}

module "security_group_rule-22" {
  source              = "git@github.com:pdaambrosio/module_security_group_rules_aws.git"
  sg_rule_id          = module.security_group.security_group_id
  sg_rule_type        = "ingress"
  sg_from_rule_port   = "22"
  sg_to_rule_port     = "22"
  sg_rule_protocol    = "tcp"
  sg_rule_cidr_blocks = ["201.69.235.30/32"]
}

module "security_group_rule-output" {
  source            = "git@github.com:pdaambrosio/module_security_group_rules_aws.git"
  sg_rule_id        = module.security_group.security_group_id
  sg_rule_type      = "egress"
  sg_from_rule_port = "0"
  sg_to_rule_port   = "65535"
  sg_rule_protocol  = "-1"
}

module "ec2_atlantis" {
  source                      = "git@github.com:pdaambrosio/module_ec2_aws.git"
  ami_id                      = data.aws_ami.atlantis.id
  instance_type               = "c3.large"
  prefix                      = "atlantis_server"
  servers                     = 1
  subnet_id                   = module.vpc.subnet_id
  security_group_id           = module.security_group.security_group_id
  associate_public_ip_address = true
}

module "ssm_parameter_vpc" {
  source          = "git@github.com:pdaambrosio/module_ssm_parameter_store_aws.git"
  ssm_name        = "/atlantis/vpc_id"
  ssm_description = "VPC ID of Atlantis Server"
  ssm_type        = "String"
  ssm_value       = module.vpc.vpc_id
}

module "ssm_parameter_igw" {
  source          = "git@github.com:pdaambrosio/module_ssm_parameter_store_aws.git"
  ssm_name        = "/atlantis/igw_id"
  ssm_description = "Internet Gateway ID of VPC"
  ssm_type        = "String"
  ssm_value       = module.vpc.aws_internet_gateway_id
}

module "ssm_parameter_sg" {
  source          = "git@github.com:pdaambrosio/module_ssm_parameter_store_aws.git"
  ssm_name        = "/atlantis/sg_id"
  ssm_description = "Security group ID of Atlantis Server"
  ssm_type        = "String"
  ssm_value       = module.security_group.security_group_id
}
