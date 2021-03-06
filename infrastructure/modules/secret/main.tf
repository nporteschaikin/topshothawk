resource "aws_secretsmanager_secret" "secret" {
  name                    = var.name
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = var.value
}

data "aws_secretsmanager_secret" "secret" {
  arn = aws_secretsmanager_secret.secret.arn
}

data "aws_secretsmanager_secret_version" "secret_version" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

