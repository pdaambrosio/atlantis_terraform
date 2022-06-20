terraform {
  cloud {
    organization = "pdaambrosio"

    workspaces {
      name = "atlantis-lab"
    }
  }
}