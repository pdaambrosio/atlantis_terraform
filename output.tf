output "ip_address" {
  value = module.ec2.ip_address
}

output "private_key" {
  value     = module.ec2.private_key
  sensitive = true
}

output "elb_dns" {
  value = module.elastic_load_balance.elb_dns
}
