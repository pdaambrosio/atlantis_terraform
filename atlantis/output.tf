output "ip_address" {
  value = module.ec2_atlantis.ip_address
}

output "private_key" {
  value     = module.ec2_atlantis.private_key
  sensitive = true
}
