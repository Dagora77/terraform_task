variable "allow_ports" {
  description = "Enter ports to open"
  type        = list(any)
  default     = ["80", "443", "3306"]
}

variable "env" {
  description = "Select env to run infrastructure"
}


/*
variable "allow_ports_bastion" {
  description = "Enter ports to open"
  type        = list(any)
  default     = ["22", "443", "3306", "80"]
}
*/
