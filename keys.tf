resource "random_id" "key_pair_name" {
  byte_length = 4
  prefix      = "${var.env_prefix}-bastion-ssh-key"
}

resource "aws_key_pair" "msk_ec2_key" {
  key_name   = random_id.key_pair_name.hex
  public_key = var.public_key_value

  tags = {
    "Name"      = "${var.env_prefix}-msk-ec2-key"
    "Terraform" = true
  }
}
