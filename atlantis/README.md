# Provisioning Atlantis

This directory utilize external Terraform modules to provision Atlantis in an AWS account with Infracost and Ansible. The modules used are:

- [module_vpc_public_subnet_aws](git@github.com:pdaambrosio/module_vpc_public_subnet_aws.git)
- [module_security_group_aws](git@github.com:pdaambrosio/module_security_group_aws.git)
- [module_security_group_rules_aws](git@github.com:pdaambrosio/module_security_group_rules_aws.git")
- [module_ec2_aws](git@github.com:pdaambrosio/module_ec2_aws.git)
- [module_ssm_parameter_store_aws](git@github.com:pdaambrosio/module_ssm_parameter_store_aws.git)
- [module_local_sensitive_file_aws](git@github.com:pdaambrosio/module_local_sensitive_file_aws.git)

The image is provisionized with [Packer](https://www.packer.io/), and the Ansible playbook is located in the [ansible](./ansible) directory.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) 0.12.0 or newer
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) 2.9.0 or newer
- [Packer](https://www.packer.io/downloads.html) 1.5.0 or newer
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) 1.16.0 or newer
- [AWS IAM Authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html) 0.3.0 or newer

## Usage

### Script

You need create a file called `atlantis_setup.sh` with the following content:

```bash
#!/bin/bash
#ATLANTIS
export ATLANTIS_GH_USER="github_username"
export ATLANTIS_GH_TOKEN="github_token"
export ATLANTIS_GH_WEBHOOK_SECRET="github_webhook_secret"
export ATLANTIS_REPO_ALLOWLIST="github.com/owner/repo/*"
export ATLANTIS_ATLANTIS_URL="ec2_external_address"

#AWS
export AWS_ACCESS_KEY_ID="aws_access_key_id"
export AWS_SECRET_ACCESS_KEY="aws_secret_access_key"
export AWS_DEFAULT_REGION="aws_default_region"

#Infracost
export INFRACOST_API_KEY="infracost_api_key" 
export GITHUB_TOKEN="github_token" 
export INFRACOST_TERRAFORM_BINARY=/usr/local/bin/terraform
```

This script will be used to export the environment variables needed to provision Atlantis and Infracost.
By the way, you need add this script to your `.gitignore` file and in this path `/atlantis/ami/packer/ansible/roles/atlantis/files/`.
Important: You need to change the values of the variables to your own and your AWS credentials must have temporary credentials and have permissions to create the resources needed.

In the future, I will refactor this code to save the credentials in the SSM parameter store.

### Packer

The Packer template is located in the [ami](./ami) directory. You need to run the following command to build the image:

```bash
packer build .
```

This command will build the image and save it in the AWS account. You can check the image in the AWS console.
The Terraform code will use this image to provision the EC2 instance.

### Terraform

```bash
# Initialize Terraform
terraform init

# Create a Terraform plan
terraform plan -out=plan.out

# Apply the Terraform plan
terraform apply plan.out
```
