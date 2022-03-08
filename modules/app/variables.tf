variable "vpc_id" {
  type        = string
  description = "valid subnets to assign to server"
}

variable "public_subnet_id_a" {
  type        = string
  description = "valid subnets to assign to server"
}

variable "public_subnet_id_b" {
  type        = string
  description = "valid subnets to assign to server"
}

variable "private_subnet_id_a" {
  type        = string
  description = "valid subnets to assign to server"
}

variable "private_subnet_id_b" {
  type        = string
  description = "valid subnets to assign to server"
}

variable "env_security_group" {
  type        = string
  description = "valid subnets to assign to server"
}

variable "aws_db_php" {
  type        = string
  description = "valid subnets to assign to server"
}

variable "aws_db_php_endpoint" {
  type        = string
  description = "valid subnets to assign to server"
}
variable "region" {
  description = "Please enter AWS region to deploy server"
  default     = "us-east-2"
}
