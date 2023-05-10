terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.54.0"
    }
  }
  backend "s3" {
    bucket         = "beehyvstatebucketforinternalproject"
    dynamodb_table = "beehyvstatelocktableforinternalproject"
    key            = "aws-starter/"
    region         = "ap-south-1"
  }
}
