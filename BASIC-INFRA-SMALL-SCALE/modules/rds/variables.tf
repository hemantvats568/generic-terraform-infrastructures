variable "db_name" {
  type = string
}
variable "db_engine_name" {
  type = string
}
variable "db_engine_version" {
  type = string
}
variable "db_username" {
  type = string
}
variable "db_password" {
  type = string
}

variable "rds_instance_class" {
  type = string
}
variable "allocated_db_storage" {
  type = number
}
variable "rds_publicly_accessible_enabled" {
  type = bool
}
variable "skip_db_final_snapshot" {
  type = bool
}
variable "db_port" {
  type = number
}
