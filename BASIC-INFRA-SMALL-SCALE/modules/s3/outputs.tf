output "regional_bucket_domain_name" {
    value = aws_s3_bucket.bucket.bucket_regional_domain_name
}

output "id" {
    value = aws_s3_bucket.bucket.id
}

output "arn" {
    value = aws_s3_bucket.bucket.arn
}