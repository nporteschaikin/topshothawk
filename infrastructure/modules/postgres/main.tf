locals {
  master_username = "master"
}

resource "random_string" "master_password" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "master_password" {
  name                    = "${var.name}-master-password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "master_password" {
  secret_id     = aws_secretsmanager_secret.master_password.id
  secret_string = random_string.master_password.result
}

data "aws_secretsmanager_secret" "master_password" {
  arn = aws_secretsmanager_secret.master_password.arn
}

data "aws_secretsmanager_secret_version" "master_password" {
  secret_id = data.aws_secretsmanager_secret.master_password.id
}

resource "random_string" "service_password" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "service_password" {
  name                    = "${var.name}-service-password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "service_password" {
  secret_id     = aws_secretsmanager_secret.service_password.id
  secret_string = random_string.service_password.result
}

data "aws_secretsmanager_secret" "service_password" {
  arn = aws_secretsmanager_secret.service_password.arn
}

data "aws_secretsmanager_secret_version" "service_password" {
  secret_id = data.aws_secretsmanager_secret.service_password.id
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
  password               = data.aws_secretsmanager_secret_version.master_password.secret_string
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = [aws_security_group.security_group.id]
  publicly_accessible    = false
}

resource "random_string" "access_password" {
  length  = 16
  special = true
}
