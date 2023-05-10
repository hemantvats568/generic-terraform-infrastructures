resource "aws_iam_policy" "s3_read_policy" {
  name        = "s3-read-policy"
  description = "Allows read access to an S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:List*"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}/*",
          "arn:aws:s3:::${var.s3_bucket_name}"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ec2_s3_access_role" {
  name = "ec2-s3-access-role-1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "ec2-s3-access-profile"

  role = aws_iam_role.ec2_s3_access_role.name
}

resource "aws_iam_role_policy_attachment" "s3_read_policy_attachment" {
  policy_arn = aws_iam_policy.s3_read_policy.arn
  role       = aws_iam_role.ec2_s3_access_role.name
}
