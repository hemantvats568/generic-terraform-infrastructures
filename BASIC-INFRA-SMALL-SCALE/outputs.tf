output "vpc_id" {
    value = module.vpc.id
}

output "public_ids" {
#    value = values(module.subnets)[*].subnet_id
    value = [for s in module.subnets : s.subnet_id[*]]
    description = "Public Subnet ID List"
}

output "aws_iam_openid_connect_provider_arn" {
    value = module.eks[0].aws_iam_openid_connect_provider_arn
}

output "aws_iam_openid_connect_provider_extract_from_arn" {
    value = module.eks[0].aws_iam_openid_connect_provider_extract_from_arn
}

output "cluster_id" {
    value = module.eks[0].cluster_id
}

output "cluster_endpoint" {
    value = module.eks[0].cluster_endpoint
}

output "cluster_certificate_authority_data" {
    value = module.eks[0].cluster_certificate_authority_data
}
