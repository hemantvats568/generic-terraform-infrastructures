variable "default_root_object" {
    type = string
    description = "Default File to be served to the cloudfront Example: index.html"
}

variable "regional_bucket_domain_name" {
    type = string
    description = "S3 Bucket Regional Domain Name"
}

variable "cloudfront_origin_bucket" {
    type = string
}

variable "cloudfront_origin_bucket_arn" {
    type = string
}