variable "vpc_id" {
  type = string
}

variable "public_subnet_id_a" {
  type = string
}

variable "public_subnet_id_b" {
  type = string
}

variable "private_subnet_id_a" {
  type = string
}

variable "private_subnet_id_b" {
  type = string
}

variable "env_security_group" {
  type = string
}

variable "user" {
  type    = string
  default = "root"
}

variable "password" {
  type    = string
  default = "5526c03ba6"
}
