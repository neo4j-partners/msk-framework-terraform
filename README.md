# msk-framework-terraform

This repository hosts a terraform module for the creation of a base network environment in AWS, on which MSK (Kafka) can be installed.

## Usage
The terraform code hosted in this repository can be easily used by creating a parent module on your local machine, in a main.tf file as shown below.
(More information about terraform modules can be found on [this](https://developer.hashicorp.com/terraform/language/modules) page)

Note the `source` parameter can be used to *either* point directly to this repository or a local copy of the terraform module.

~~~
#main.tf file for deploying msk-framework-terraform
module "msk-framework-environment" {
  source         = "github.com/edrandall-dev/msk-framework-terraform"
  //source       = "../msk-framework-terraform"

  //Required values (no defaults are provided)
  public_key_value = "ssh-rsa AAAAB3NzaC1A.....b+oTz7tb0WF2aiOPp0="
  private_key_path = "~/.ssh/my-ssh-key"

  //The following Optional values can be omitted if the defaults are satisfactory.

  //Default is "t3.medium"
  bastion_instance_type = "t3.micro"

  //Default is "10.0.0.0/16"
  vpc_base_cidr = "10.0.0.0/16"

  //Default is "0.0.0.0/0"
  ssh_source_cidr   = "0.0.0.0/0"

  //Default is "msk-tf-cloud"
  env_prefix = "my-neo4j-env"

  //Default is "us-east-1"
  target_region = "us-east-1"
}

output "ssh_commands" {
  value = module.msk-framework-environment.ssh_commands
}
~~~

## AWS Resources
Assuming that defaults were used, the following resources are created by the terraform module:

Users are reminded that the deployment of cloud resources will incur costs.

 - 1 VPC, with a CIDR Range of 10.0.0.0/16
 - 4 Subnets, distributed evenly across 3 Availability zones, with the following CIDR Ranges:
   - 10.0.1.0/24 [Private]
   - 10.0.2.0/24 [Private]
   - 10.0.3.0/24 [Private]
   - 10.0.10.0/24 [Public]
 - An Internet Gateway
 - A NAT Gateway
 - Routes, Route Tables & Associations

## Prerequisites

### Terraform and AWS CLI configuration
In order to use this module, terraform needs to be properly installed and configured.  Whilst this is out of the scope of this README file, an example `provider.tf` file is shown below.  The [official terraform documentation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) explains how to get terraform up and running on a local machine.  Alternatively, [Terraform Cloud](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started) is another option.

~~~
//Configure the terraform backend (S3) and aws provider
terraform {
  backend "s3" {
    bucket  = "<s3-bucketname goes here>"
    key     = "terraform.tfstate"
    region  = "us-east-1"
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

//Specify which AWS region and profile should be used by default
provider "aws" {
  region  = "us-east-1"
}
~~~

