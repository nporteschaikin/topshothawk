resource "aws_security_group" "security_group" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "ssh"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "all egress"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "topshothawk-${terraform.workspace}-bastion"
  }
}

data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "server" {
  ami                         = data.aws_ami.latest_ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = var.key_pair_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.security_group.id]
  associate_public_ip_address = true

  tags = {
    "Name" = "topshothawk-${terraform.workspace}-bastion"
  }
}

resource "aws_eip" "nat" {
  instance = aws_instance.server.id
  vpc      = true
}
