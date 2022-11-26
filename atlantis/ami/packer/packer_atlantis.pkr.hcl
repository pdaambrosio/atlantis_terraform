packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "atlantis" {
  ami_name        = "${var.name}-${local.timestamp}"
  instance_type   = var.instance_type
  region          = var.region
  ami_description = "from {{.SourceAMI}}"
  tags = {
    Name          = "${var.name}-${local.timestamp}"
    OS_Version    = "Ubuntu 18.04"
    Release       = "Latest"
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Environment   = var.environment
  }
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-bionic-18.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "atlantis"
  sources = [
    "source.amazon-ebs.atlantis"
  ]

  provisioner "ansible" {
    playbook_file          = "./ansible/main.yml"
    user                   = "ubuntu"
    extra_arguments        = ["--extra-vars", "ansible_python_interpreter=/usr/bin/python3"]
    ansible_env_vars       = ["ANSIBLE_HOST_KEY_CHECKING=False"]
    ansible_ssh_extra_args = ["-oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa"]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
    custom_data = {
      source_ami_name = "${build.SourceAMIName}"
    }
  }
}
