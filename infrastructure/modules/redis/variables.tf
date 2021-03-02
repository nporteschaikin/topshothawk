variable "name" {}
variable "vpc_id" {}
variable "security_groups" {
  type = list(string)
}
variable "subnets" {
  type = list(string)
}
