#variable "eks_launch_type" {
#  type = string
#}

variable "eks_cluster_name" {
  type = string
}

variable "eks_node_group_name" {
  type = string
}

variable "eks_desired_num_of_nodes" {
  type = number
}

variable "eks_max_num_of_nodes" {
  type = number
}

variable "eks_min_num_of_nodes" {
  type = number
}

variable "subnet_ids" {
  type = list(string)
}

variable "node_instance_type" {
  type = string
}

variable "eks_capacity_type" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "eks_node_endpoint_private_access" {
  type = bool
}
