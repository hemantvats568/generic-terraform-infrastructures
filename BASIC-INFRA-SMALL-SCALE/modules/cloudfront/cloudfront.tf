locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_origin_access_control" "cloudfront_oac" {
  name                              = "cloudfront_oac"
  description                       = "oac for cloudfront"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [aws_cloudfront_origin_access_control.cloudfront_oac]
  origin {
    domain_name       = var.regional_bucket_domain_name
    origin_id         = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_oac.id
  }

  enabled             = true
  default_root_object = var.default_root_object

 default_cache_behavior {
    allowed_methods   = ["GET", "HEAD"]
    cached_methods    = ["GET", "HEAD"]
    target_origin_id  = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_100"

  viewer_certificate {
      cloudfront_default_certificate = true
  }

}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = var.cloudfront_origin_bucket

  policy = <<POLICY
{
   "Version": "2012-10-17",
   "Statement": [
     {
       "Sid": "Access-to-CloudFront",
       "Principal": {
          "Service": "cloudfront.amazonaws.com"
       },
       "Action": "s3:GetObject",
       "Effect": "Allow",
       "Resource": "${var.cloudfront_origin_bucket_arn}/*",
       "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "${aws_cloudfront_distribution.s3_distribution.arn}"
                }
            }
     }
   ]
}
POLICY
}