terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "4.54.0"
        }
    }
    backend s3 {
        bucket = ""
        dynamodb_table = ""
        key = ""
        region = ""
    }
}
