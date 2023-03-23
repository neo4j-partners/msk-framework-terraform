# msk-framework-terraform

This repository hosts a terraform module which performs the following tasks (when invoked as a child module):

1 - Creates of a base network environment in AWS, consisting of:
 - 1 VPC, with a CIDR Range of 10.0.0.0/16
 - 4 Subnets, distributed evenly across 3 Availability zones, with the following CIDR Ranges:
   - ```10.0.1.0/24  [Private]```
   - ```10.0.2.0/24  [Private]```
   - ```10.0.3.0/24  [Private]```
   - ```10.0.10.0/24 [Public]```
 - An Internet Gateway
 - A NAT Gateway
 - Routes, Route Tables & Associations

2 - Installs an MSK (Kafka) Cluster on AWS

3 - Installs 2 EC2 instances
 - A msk-client EC2 instance, which has the following things pre-installed (via a user-data script):
   - The kafka client application and libraries
   - A script called, ```create-topic.sh``` which created a topic on the MSK (kafka) cluster
   - A client.properties file
 - A bastion EC2 instance, which can be used as a 'jump server' to connect from the internet to the msk-client EC2 instance

## Prerequisites

### Terraform and AWS CLI configuration
In order to use this module, terraform needs to be properly installed and configured.  Whilst this is out of the scope of this README file, an example `provider.tf` file is shown below.  The [official terraform documentation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) explains how to get terraform up and running on a local machine.  Alternatively, [Terraform Cloud](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started) is another option.

### Create a provider.tf file
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

### Configure an SSH Key
#### Create an SSH Keypair
Create a new ssh-key for use with this environment, using the *ssh-keygen* command:
```
ssh-keygen -N "" -f my-new-ssh-key
```
> The private key should never be shared, and its file location should be the value for `private_key_path` in the main.tf file example shown below.  The *contents* of the public key should be given as the value for `public_key_path`

#### Ensure the correct permissions on the new keypair
```
chmod 400 my-new-ssh-key
chmod 644 my-new-ssh-key.pub
```

#### Ensure ssh-agent is running
```
eval $(ssh-agent)
```

#### Add your new key to the ssh-agent 
```
ssh-add my-new-ssh-key
```

#### Check that your new key has been loaded into the ssh-agent
```
ssh-add -l
```

## Usage
The terraform code hosted in this repository can be easily used by creating a parent module on your local machine, in a main.tf file as shown below.
(More information about terraform modules can be found on [this](https://developer.hashicorp.com/terraform/language/modules) page)

Note the `source` parameter can be used to *either* point directly to this repository or a local copy of the terraform module.


### Create a main.tf file 
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
  env_prefix = "msk-tf-cloud"

  //Default is "us-east-1"
  target_region = "us-east-1"
}

output "bastion_ssh_command" {
  value = module.msk-framework-environment.bastion_ssh_command
}

output "msk_test_ssh_command" {
  value = module.msk-framework-environment.msk_test_ssh_command
}


~~~

## Validate Terraform Code
Once the main.tf file has been properly created, the terraform configuration can be validated:
```
terraform validate
```

## Deploy Resources (plan & deploy)
```
terraform plan
```

```
terraform apply -auto-approve
```

## Connecting to the bastion
Once the ```terraform apply``` has completed. The bastion can be connected to by using the first command which is shown as part of the terraform output.  For example:

```
ssh -A -o StrictHostKeyChecking=no ec2-user@12.34.56.78
```

Once connected to the bastion instance, a further connection can be made (from the bastion instance) onto the msk-test instance which resides in the first private subnet (and only has a private IP address). This can be done with the second command which is shown as part of the terraform output.  For example:

```
ssh -A -o StrictHostKeyChecking=no ec2-user@10.0.11.22
```

## AWS Resources
Users are reminded that the deployment of cloud resources will incur costs.  



> If you tear down the environment and start again, you may need to delete and re-add your ssh-key into the ssh-agent.  The command ```ssh-add -D``` can be used to delete all entries from ssh-agent.