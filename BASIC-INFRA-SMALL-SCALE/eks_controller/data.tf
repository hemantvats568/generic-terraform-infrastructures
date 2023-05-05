data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}

output "lbc_iam_policy" {
  value = data.http.lbc_iam_policy.body
}

data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "terraform-starter-project-bucket"
    key    = "s3/terraform.tfstate"
    region = "us-east-2"
  }
}

