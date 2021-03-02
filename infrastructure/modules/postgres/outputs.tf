output "endpoint" {
  value = aws_db_instance.instance.endpoint
}

output "database_name" {
  value = aws_db_instance.instance.name
}

output "service_username" {
  value = var.service_username
}

output "service_password" {
  value     = data.aws_secretsmanager_secret_version.service_password.secret_string
  sensitive = true
}
