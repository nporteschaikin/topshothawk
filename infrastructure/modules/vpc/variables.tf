variable "private_subnet_numbers" {
  default = {
    "us-east-1a" = 1
    "us-east-1b" = 2
  }
}

variable "public_subnet_numbers" {
  default = {
    "us-east-1a" = 3
    "us-east-1b" = 4
  }
}

