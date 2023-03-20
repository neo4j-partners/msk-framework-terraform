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
  count = var.private_subnet_qty
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
  //check cidr range doesn't overlap
  cidr_block              = cidrsubnet(var.vpc_base_cidr, 8, 10)
  availability_zone       = join("", ["${var.target_region}", "${var.availability_zones[count.index]}"])
  map_public_ip_on_launch = true

  tags = {
    "Name"      = "${var.env_prefix}-public-subnet-${var.availability_zones[count.index]}"
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

resource "aws_route_table" "msk_public_subnet_rt" {
  vpc_id = aws_vpc.msk_vpc.id
  tags = {
    "Name"      = "${var.env_prefix}-public-subnet-rt"
    "Terraform" = true
  }
}

resource "aws_route" "msk_public_subnet_route" {
  route_table_id         = aws_route_table.msk_public_subnet_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.msk_igw.id
}

resource "aws_route_table_association" "msk_public_route_assoc" {
  count          = var.subnet_qty
  subnet_id      = aws_subnet.msk_public_subnet[count.index].id
  route_table_id = aws_route_table.msk_public_subnet_rt.id
}
