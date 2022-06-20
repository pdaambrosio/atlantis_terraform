variable "prefix" {
  default = "webapp"
}

variable "lb_internal" {
  default = false
}

variable "type_loadbalancer" {
  default = "network"
}

variable "subnet_id" {
  default = "subnet-12345678"
}

variable "tg_port" {
  default = 80
}

variable "tg_protocol" {
  default = "TCP"
}

variable "tg_vpc_id" {
  default = "vpc-12345678"
}

variable "listerner_port" {
  default = 80
}

variable "listener_protocol" {
  default = "TCP"
}

variable "listerner_type" {
  default = "forward"
}

variable "tg_number_instances" {
  default = 1
}

variable "tg_instances_id" {
  default = ["i-12345678"]
}

variable "tg_instances_port" {
  default = 80
}
