variable "name" {}
variable "vpc_id" {}
variable "service_username" {
  default = "service"
}
variable "security_groups" {
  type = list(string)
}
variable "subnets" {
  type = list(string)
}
