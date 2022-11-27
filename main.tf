data "aws_ssm_parameter" "vpc_id" {
  name = "/atlantis/vpc_id"
}

data "aws_ssm_parameter" "igw_id" {
  name = "/atlantis/igw_id"
}

data "aws_ssm_parameter" "sg_id" {
  name = "/atlantis/sg_id"
}

module "public_subnets" {
  source              = "git@github.com:pdaambrosio/module_public_subnet_aws.git"
  aws_vpc_id          = data.aws_ssm_parameter.vpc_id.value
  public_subnet_name  = "webapps_subnet"
  igw_name            = "webapps_igw"
  internet_gateway_id = data.aws_ssm_parameter.igw_id.value
  cidr_public_subnet  = "10.1.20.0/24"
}

module "security_group" {
  source         = "git@github.com:pdaambrosio/module_security_group_aws.git"
  sg_vpc_id      = data.aws_ssm_parameter.vpc_id.value
  sg_name        = "webapps_sg"
  sg_description = "HTTP, HTTPS and SSH traffic to webapps"
}

module "security_group_rule-80" {
  source            = "git@github.com:pdaambrosio/module_security_group_rules_aws.git"
  sg_rule_id        = module.security_group.security_group_id
  sg_rule_type      = "ingress"
  sg_from_rule_port = "80"
  sg_to_rule_port   = "80"
  sg_rule_protocol  = "tcp"
}

module "security_group_rule-atlantis" {
  source                   = "git@github.com:pdaambrosio/module_security_group_rules_sgid_aws.git"
  sg_rule_id               = module.security_group.security_group_id
  sg_rule_type             = "ingress"
  sg_from_rule_port        = "0"
  sg_to_rule_port          = "65535"
  sg_rule_protocol         = "-1"
  source_security_group_id = data.aws_ssm_parameter.sg_id.value
}

module "security_group_rule-output" {
  source            = "git@github.com:pdaambrosio/module_security_group_rules_aws.git"
  sg_rule_id        = module.security_group.security_group_id
  sg_rule_type      = "egress"
  sg_from_rule_port = "0"
  sg_to_rule_port   = "65535"
  sg_rule_protocol  = "-1"
}

module "ec2" {
  source                      = "git@github.com:pdaambrosio/module_ec2_aws.git"
  prefix                      = "webapps"
  servers                     = 3
  ami_id                      = ""
  region                      = var.region_subnet
  subnet_id                   = module.public_subnets.subnet_id
  security_group_id           = module.security_group.security_group_id
  associate_public_ip_address = true
}

module "elastic_load_balance" {
  source              = "git@github.com:pdaambrosio/module_elb_aws.git"
  prefix              = "webapps"
  lb_internal         = false
  type_loadbalancer   = "network"
  subnet_id           = module.public_subnets.subnet_id
  tg_port             = 80
  tg_protocol         = "TCP"
  tg_vpc_id           = data.aws_ssm_parameter.vpc_id.value
  listerner_port      = 80
  listener_protocol   = "TCP"
  listerner_type      = "forward"
  tg_number_instances = 2
  tg_instances_id     = module.ec2.instances_id
  tg_instances_port   = 80
}

module "elastic_block_storage" {
  source                = "git@github.com:pdaambrosio/module_ebs_aws.git"
  ebs_availability_zone = module.ec2.availability_zone[0]
  ebs_size              = 20
  ebs_type              = "gp2"
  ebs_iops              = 0
  ebs_device_name       = "/dev/sdh"
  ebs_instance_id       = module.ec2.instances_id[0]
}

module "local_private_key" {
  source             = "git@github.com:pdaambrosio/module_local_sensitive_file_aws.git"
  local_file_content = module.ec2.private_key
  prefix             = "webapps"
  user_path          = "/home/kali-user/"
  depends_on = [
    module.ec2
  ]
}
