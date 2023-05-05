variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The CIDR block for the VPC."
}

variable "tenancy" {
  type        = string
  default     = "default"
  description = "A tenancy option for instances launched into the VPC."
}
