variable "bugsnag_api_key" {}
variable "command" {
  type = list(string)
}
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
variable "deployment_maximum_percent" {
  default = 200
}
variable "deployment_minimum_healthy_percent" {
  default = 100
}
variable "desired_count" {
  default = 1
}
variable "subnets" {
  type = list(string)
}
