variable "command" {}
variable "ecr_repository_url" {}
variable "ecs_cluster_id" {}
variable "service_name" {}
variable "cloudwatch_log_group" {}
variable "vpc_id" {}
variable "database_endpoint" {}
variable "database_username" {}
variable "database_password" {}
variable "database_name" {}
variable "redis_endpoint" {}
variable "subnets" {
  type = list(string)
}
