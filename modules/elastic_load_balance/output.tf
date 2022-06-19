output "elb_dns" {
  value = aws_lb.lb-instances.dns_name
}
