# terraform {
#   cloud {
#     organization = "ccoe-ttech"
#     workspaces {
#       name = "atlantis-aws"
#     }
#   }
# }

terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "ccoe-ttech"
    workspaces {
      name = "atlantis-aws"
    }
  }
}