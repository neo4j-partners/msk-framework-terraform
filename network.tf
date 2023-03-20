resource "aws_vpc" "msk_vpc" {
  cidr_block           = var.vpc_base_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name"      = "${var.env_prefix}-vpc"
    "Terraform" = true
  }
}

resource "aws_subnet" "msk_private_subnet" {
  count                   = var.private_subnet_qty
  vpc_id                  = aws_vpc.msk_vpc.id
  cidr_block              = cidrsubnet(var.vpc_base_cidr, 8, count.index + 1)
  availability_zone       = join("", ["${var.target_region}", "${var.availability_zones[count.index]}"])
  map_public_ip_on_launch = true

  tags = {
    "Name"      = "${var.env_prefix}-private-subnet-${var.availability_zones[count.index]}"
    "Terraform" = true
  }
}

resource "aws_subnet" "msk_public_subnet" {
  vpc_id                  = aws_vpc.msk_vpc.id
  cidr_block              = cidrsubnet(var.vpc_base_cidr, 8, 10)
  availability_zone       = join("", ["${var.target_region}", "a"])
  map_public_ip_on_launch = true

  tags = {
    "Name"      = "${var.env_prefix}-public-subnet"
    "Terraform" = true
  }
}

resource "aws_internet_gateway" "msk_igw" {
  vpc_id = aws_vpc.msk_vpc.id

  tags = {
    "Name"      = "${var.env_prefix}-vpc-igw"
    "Terraform" = true
  }
}

resource "aws_nat_gateway" "msk_ngw" {
  allocation_id = aws_eip.msk_eip.id
  subnet_id     = aws_subnet.msk_public_subnet.id

  tags = {
    "Name"      = "${var.env_prefix}-ngw"
    "Terraform" = true
  }

  depends_on = [aws_internet_gateway.msk_igw]
}

resource "aws_eip" "msk_eip" {
  vpc = true

  tags = {
    "Name"      = "${var.env_prefix}-eip"
    "Terraform" = true
  }
}


resource "aws_route_table" "msk_public_subnet_rt" {
  vpc_id = aws_vpc.msk_vpc.id
  tags = {
    "Name"      = "${var.env_prefix}-public-subnet-rt"
    "Terraform" = true
  }
}

resource "aws_route_table" "msk_private_subnet_rt" {
  vpc_id = aws_vpc.msk_vpc.id
  tags = {
    "Name"      = "${var.env_prefix}-private-subnet-rt"
    "Terraform" = true
  }
}

resource "aws_route" "msk_public_subnet_route" {
  route_table_id         = aws_route_table.msk_public_subnet_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.msk_igw.id

}

resource "aws_route" "msk_private_subnet_route" {
  route_table_id         = aws_route_table.msk_private_subnet_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.msk_ngw.id

}

resource "aws_route_table_association" "msk_private_route_assoc" {
  count          = var.private_subnet_qty
  subnet_id      = aws_subnet.msk_private_subnet[count.index].id
  route_table_id = aws_route_table.msk_private_subnet_rt.id

}

resource "aws_route_table_association" "msk_public_route_assoc" {
  count          = 1
  subnet_id      = aws_subnet.msk_public_subnet.id
  route_table_id = aws_route_table.msk_public_subnet_rt.id

}