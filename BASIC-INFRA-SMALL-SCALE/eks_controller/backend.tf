terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.54"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 2.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.11"
    }
  }
  backend s3 {
    bucket         = "terraform-starter-project-bucket"
    dynamodb_table = "terraform-state-lock-dynamodb"
    key            = "controller/terraform.tfstate"
    region         = "us-east-2"
  }
}
