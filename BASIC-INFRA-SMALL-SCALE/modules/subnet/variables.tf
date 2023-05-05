variable "vpc_id" {
  type        = string
  description = "VPC Id."
}

variable "subnet_cidr" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "route_table_id" {
  type = string
}