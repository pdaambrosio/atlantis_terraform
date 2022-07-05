variable "bucket_name" {
  default = "module-s3-bucket"
}

variable "acl" {
  default = "private"
}

variable "tags" {
  type = map(string)
}

variable "filename" {
}
