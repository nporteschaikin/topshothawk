data "aws_region" "current" {}

/* VPC */

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = "topshothawk-${terraform.workspace}"
  }
}

/* Public subnets */

resource "aws_subnet" "public_subnets" {
  for_each = var.public_subnet_numbers

  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, each.value)
  map_public_ip_on_launch = true

  tags = {
    "Name" = "topshothawk-${terraform.workspace}-public"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "topshothawk-${terraform.workspace}-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    "Name" = "topshothawk-${terraform.workspace}-public"
  }
}

resource "aws_route_table_association" "public_route_table_associations" {
  for_each = aws_subnet.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

/* Private subnets */

resource "aws_subnet" "private_subnets" {
  for_each = var.private_subnet_numbers

  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, each.value)

  tags = {
    "Name" = "topshothawk-${terraform.workspace}-private"
  }
}

/* NAT */

resource "aws_security_group" "nat" {
  name   = "topshothawk-${terraform.workspace}-nat"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [for subnet in aws_subnet.private_subnets : subnet.cidr_block]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [for subnet in aws_subnet.private_subnets : subnet.cidr_block]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "topshothawk-${terraform.workspace}-nat"
  }
}

resource "aws_instance" "nat" {
  ami                         = "ami-01623d7b"
  instance_type               = "t3.micro"
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.nat.id]
  subnet_id                   = aws_subnet.public_subnets["us-east-1a"].id
  associate_public_ip_address = true
  source_dest_check           = false

  tags = {
    Name = "topshothawk-${terraform.workspace}-nat"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat.id
  }

  tags = {
    "Name" = "topshothawk-${terraform.workspace}-private"
  }
}

resource "aws_route_table_association" "private_route_table_associations" {
  for_each = aws_subnet.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}
