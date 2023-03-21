locals {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
       },
       {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "kafkaconnect.amazonaws.com"
        }
      }
    ]
  })
}

variable "vpc_base_cidr" {
  description = "The base of the address range to be used by the VPC and corresponding Subnets"
  type        = string
  default     = "10.10.0.0/16"
  validation {
    condition     = can(regex("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$", var.vpc_base_cidr))
    error_message = "Invalid IP address provided for the vpc_base_cidr block variable.  A valid example would be 10.10.0.0/16"
  }
}

variable "ssh_source_cidr" {
  description = "The cidr range which is allowed to connect to the EC2 instances via SSH. Default will be fully open: 0.0.0.0/0"
  type        = string
  default     = "0.0.0.0/0"
  validation {
    condition     = can(regex("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))$", var.ssh_source_cidr))
    error_message = "Invalid IP address provided for the ssh_source_cidr variable.  A valid example would be 0.0.0.0/16"
  }
}

variable "env_prefix" {
  description = "A prefix which is useful for tagging and naming"
  type        = string
}

variable "target_region" {
  description = "The region in which the environment will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "A list containing 3 AZs"
  type        = list(string)
  default     = ["a", "b", "c"]
}

variable "private_subnet_qty" {
  description = "The number of subnets in the environment - should remain at 3"
  type        = number
  default     = 3
}

variable "bastion_instance_type" {
  description = "The type of bastion EC2 instance to be deployed"
  type        = string
  default     = "t3.micro"
}

variable "public_key_value" {
  description = "The public SSH key, generated on the the local environment"
}

variable "private_key_path" {
  description = "The location of the private SSH key, generated on the the local environment"
}
