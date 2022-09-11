terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "ccoe-ttech"
    workspaces {
      name = "atlantis-instance-aws"
    }
  }
}