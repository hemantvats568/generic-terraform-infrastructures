variable "bucket_name" {
  type = string
}

variable "force_destroy" {
  type = bool
}

variable "s3_versioning_enabled" {
  type = string
  default = "Enabled" #Enabled or Disabled
}