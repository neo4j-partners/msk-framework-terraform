resource "aws_instance" "msk_bastion_instance" {
  ami                    = data.aws_ami.latest_amazon.id

  instance_type          = "t3.micro"
  key_name               = aws_key_pair.msk_ec2_key.id
  subnet_id              = aws_subnet.msk_public_subnet.id
  vpc_security_group_ids = [
    "${aws_security_group.msk_public_sg.id}",
    "${aws_security_group.msk_private_sg.id}"
    ]
  
  tags = {
    "Name"      = "${var.env_prefix}-bastion"
    "Terraform" = true
  }
}

resource "aws_instance" "msk_client_instance" {
  ami                    = data.aws_ami.latest_amazon.id

  instance_type          = "t3.micro"
  key_name               = aws_key_pair.msk_ec2_key.id
  subnet_id              = aws_subnet.msk_private_subnet[0].id
  vpc_security_group_ids = [
    "${aws_security_group.msk_private_sg.id}"
    ]

  iam_instance_profile = aws_iam_instance_profile.msk_instance_profile.name
  
  
  user_data = templatefile(
    "${path.module}/msk.tftpl",
    {
      msk_brokers = data.aws_msk_cluster.the_msk_cluster.bootstrap_brokers_sasl_iam
    }
  )

  tags = {
    "Name"      = "${var.env_prefix}-msk-client"
    "Terraform" = true
  }
}

data "aws_ami" "latest_amazon" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}