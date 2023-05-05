resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_iam_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = ["${aws_security_group.eks_cluster_sg.id}"]
    endpoint_private_access = var.eks_node_endpoint_private_access
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
  ]
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.eks_node_group_name
  node_role_arn   = aws_iam_role.eks_node_iam_role.arn
  subnet_ids      = var.subnet_ids

  instance_types  = [var.node_instance_type]
  capacity_type   = var.eks_capacity_type

  scaling_config {
    desired_size = var.eks_desired_num_of_nodes
    max_size     = var.eks_max_num_of_nodes
    min_size     = var.eks_min_num_of_nodes
  }
  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]
}

resource "aws_security_group" "eks_cluster_sg" {
  name = "eks-cluster-sg"
  vpc_id      = var.vpc_id
  description = "EKS Cluster Security Group"

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
