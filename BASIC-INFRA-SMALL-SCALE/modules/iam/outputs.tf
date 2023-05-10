output "s3_iam_role" {
  value = aws_iam_role.ec2_s3_access_role.name
}

output "aws_iam_instance_profile" {
  value = aws_iam_instance_profile.instance_profile.name
}