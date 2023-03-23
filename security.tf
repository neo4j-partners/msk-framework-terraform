resource "aws_security_group" "msk_public_sg" {
  name   = "${var.env_prefix}_public_sg"
  vpc_id = aws_vpc.msk_vpc.id

  // no restrictions on ssh traffic from the internet
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"      = "${var.env_prefix}-public-sg"
    "Terraform" = true
  }
}

resource "aws_security_group" "msk_private_sg" {
  name   = "${var.env_prefix}_private_sg"
  vpc_id = aws_vpc.msk_vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["${var.vpc_base_cidr}"]
    
    security_groups = [
      aws_security_group.msk_public_sg.id
    ]
    
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"      = "${var.env_prefix}-private-sg"
    "Terraform" = true
  }
}