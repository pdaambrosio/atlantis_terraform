variable "name" {
  type        = string
  description = "Name of the resource"
  default     = "atlantis"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "IAC"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
  default     = "t2.micro"
}
