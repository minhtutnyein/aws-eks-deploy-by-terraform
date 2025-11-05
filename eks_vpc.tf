# locals {
#   name_prefix = var.stack_name
# }

data "aws_availability_zones" "eks_available" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.eks_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

# Subnets (public)
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.eks_public_subnet_cidrs[0]
  availability_zone       = data.aws_availability_zones.eks_available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-public-subnet-1"
  }
}
resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.eks_public_subnet_cidrs[1]
  availability_zone       = data.aws_availability_zones.eks_available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-public-subnet-2"
  }
}
resource "aws_subnet" "public_d" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.eks_public_subnet_cidrs[2]
  availability_zone       = data.aws_availability_zones.eks_available.names[2]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-public-subnet-3"
  }
}

# Subnets (private)
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.eks_private_subnet_cidrs[0]
  availability_zone = data.aws_availability_zones.eks_available.names[0]
  tags = {
    Name = "${var.prefix}-private-subnet-1"
  }
}
resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.eks_private_subnet_cidrs[1]
  availability_zone = data.aws_availability_zones.eks_available.names[1]
  tags = {
    Name = "${var.prefix}-private-subnet-2"
  }
}
resource "aws_subnet" "private_d" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = var.eks_private_subnet_cidrs[2]
  availability_zone = data.aws_availability_zones.eks_available.names[2]
  tags = {
    Name = "${var.prefix}-private-subnet-3"
  }
}

# Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id
  tags   = { Name = "${var.prefix}-PublicRouteTable" }
}

resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks_igw.id
}

# Associate public subnets to route table
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_d" {
  subnet_id      = aws_subnet.public_d.id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway
resource "aws_eip" "nat" {
  # Use domain = "vpc" for a VPC Elastic IP (don't set the VPC id here)
  domain = "vpc"

  tags = { Name = "${var.prefix}-NATGatewayEIP" }
}

resource "aws_nat_gateway" "eks_natgw" {
  # use the EIP allocation id
  allocation_id = aws_eip.nat.allocation_id
  subnet_id     = aws_subnet.public_c.id
  tags          = { Name = "${var.prefix}-NATGateway" }
}

# Private route tables and routes via NAT
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.eks_vpc.id
  tags   = { Name = "${var.prefix}-PrivateRouteTableAPNORTHEAST1A" }
}
resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.eks_vpc.id
  tags   = { Name = "${var.prefix}-PrivateRouteTableAPNORTHEAST1C" }
}
resource "aws_route_table" "private_d" {
  vpc_id = aws_vpc.eks_vpc.id
  tags   = { Name = "${var.prefix}-PrivateRouteTableAPNORTHEAST1D" }
}

resource "aws_route" "private_a_nat" {
  route_table_id         = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.eks_natgw.id
}
resource "aws_route" "private_c_nat" {
  route_table_id         = aws_route_table.private_c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.eks_natgw.id
}
resource "aws_route" "private_d_nat" {
  route_table_id         = aws_route_table.private_d.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.eks_natgw.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}
resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_c.id
}
resource "aws_route_table_association" "private_d" {
  subnet_id      = aws_subnet.private_d.id
  route_table_id = aws_route_table.private_d.id
}