locals {
  master_username = "master"
}

resource "random_string" "master_password" {
  length  = 16
  special = true
}

module "master_password" {
  source = "./../secret"

  name  = "${var.name}-master-password"
  value = random_string.master_password.result
}

resource "random_string" "service_password" {
  length  = 16
  special = true
}

module "service_password" {
  source = "./../secret"

  name  = "${var.name}-service-password"
  value = random_string.master_password.result
}

resource "aws_security_group" "security_group" {
  name   = var.name
  vpc_id = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    security_groups = var.security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = var.name
  subnet_ids = var.subnets
}

resource "aws_db_instance" "instance" {
  identifier             = var.name
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "9.6"
  instance_class         = "db.t3.micro"
  name                   = "topshothawk"
  username               = local.master_username
  password               = module.master_password.value
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = [aws_security_group.security_group.id]
  publicly_accessible    = false
}
