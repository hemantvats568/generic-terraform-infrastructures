variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC."
}

variable "tenancy" {
  type        = string
  description = "A tenancy option for instances launched into the VPC."
}

variable "bucket_name" {
  type        = string
  description = "S3 Bucket Name"
}

variable "s3_bucket_enabled" {
  type = bool
}

variable "s3_versioning_enabled" {
  type = string
}

variable "force_destroy" {
  type        = bool
  description = "S3 Bucket Force Destroy"
}

variable "frontend_cloudfront_enabled" {
  type = bool
}

variable "default_root_object" {
  type        = string
  description = "Default File to be served to the cloudfront Example: index.html"
}

variable "public_key_path" {
  type      = string
  sensitive = true
}

variable "frontend_ec2_enabled" {
  type = bool
}

variable "frontend_asg_key_name" {
  type = string
}

variable "frontend_asg_instance_type" {
  type = string
}

variable "frontend_asg_public_ip_enabled" {
  type = bool
}

variable "frontend_asg_desired_capacity" {
  type = number
}

variable "frontend_asg_max_size" {
  type = number
}

variable "frontend_asg_min_size" {
  type = number
}

variable "frontend_asg_schedule_action_name_upscale" {
  type = string
}

variable "frontend_asg_schedule_action_name_downscale" {
  type = string
}

#variable "frontend_asg_recurrence_schedule_upscale" {
#  type = string
#}
#
#variable "frontend_asg_recurrence_schedule_downscale" {
#  type = string
#}

variable "frontend_asg_scheduled_desired_capacity" {
  type = number
}

variable "frontend_asg_scheduling_enabled" {
  type = bool
}

variable "frontend_user_data" {
  type    = string
  default = "frontend_userdata.sh"
}

variable "start_time_upscale" {
  type = string
}

variable "end_time_upscale" {
  type = string
}

variable "start_time_downscale" {
  type = string
}

variable "end_time_downscale" {
  type = string
}

variable "backend_ec2_enabled" {
  type = string
}

variable "backend_asg_key_name" {
  type = string
}

variable "backend_asg_instance_type" {
  type = string
}

variable "backend_asg_public_ip_enabled" {
  type = bool
}


variable "backend_asg_desired_capacity" {
  type = number
}

variable "backend_asg_max_size" {
  type = number
}

variable "backend_asg_min_size" {
  type = number
}

variable "backend_user_data" {
  type    = string
  default = "backend_userdata.sh"
}

variable "backend_asg_schedule_action_name_upscale" {
  type = string
}

variable "backend_asg_schedule_action_name_downscale" {
  type = string
}

#variable "backend_asg_recurrence_schedule_upscale" {
#  type = string
#}
#
#variable "backend_asg_recurrence_schedule_downscale" {
#  type = string
#}

variable "backend_asg_scheduled_desired_capacity" {
  type = number
}

variable "backend_asg_scheduling_enabled" {
  type = bool
}

variable "subnet_type" {
  description = "Which route table should be added to the specified subnet"
  type        = map(string)
}

variable "subnet_names" {
  type = list(string)
}

variable "subnet_zones" {
  type = map(string)
}

variable "rds_enabled" {
  type = bool
}

variable "rds_instance_name" {
  type        = string
  description = "Name of the RDS database"
}
variable "rds_instance_class" {
  type        = string
  description = "RDS instance type"
}
variable "db_username" {
  type        = string
  default     = ""
  description = "Username for the RDS database"
}
variable "db_password" {
  type        = string
  default     = ""
  description = "Password for the RDS database"
}

variable "rds_publicly_accessible_enabled" {
  type        = bool
  description = "Public access for the RDS database"
}
variable "allocated_db_storage" {
  type        = number
  description = "Allocation of Storage for RDS database"
}
variable "db_engine_name" {
  type        = string
  description = "Engine name for the RDS database"
}
variable "db_engine_version" {
  type        = string
  description = "Engine version for the RDS database"
}
variable "db_port" {
  type = number
}
variable "skip_db_final_snapshot" {
  type = bool
}

variable "backend_lb_asg_name" {
  type = string
}

variable "backend_lb_tg_asg_name" {
  type = string
}

variable "frontend_lb_asg_name" {
  type = string
}

variable "frontend_lb_tg_asg_name" {
  type = string
}

variable "frontend_tg_port" {
  type = string
}

variable "frontend_listener_port" {
  type = string
}
variable "frontend_asg_policy_upscale" {
  type = string
}

variable "frontend_asg_scaling_adjustment_upscale" {
  type = number
}

variable "frontend_asg_adjustment_type_upscale" {
  type = string
}

variable "frontend_asg_cooldown_upscale" {
  type = number
}

variable "frontend_cloudwatch_up_alarm_name" {
  type = string
}

variable "frontend_cloudwatch_up_comparison_operator" {
  type = string
}

variable "frontend_cloudwatch_up_period" {
  type = number
}

variable "frontend_cloudwatch_up_threshold" {
  type = number
}

variable "frontend_asg_policy_downscale" {
  type = string
}

variable "frontend_asg_scaling_adjustment_downscale" {
  type = number
}

variable "frontend_asg_adjustment_type_downscale" {
  type = string
}

variable "frontend_asg_cooldown_downscale" {
  type = number
}

variable "frontend_cloudwatch_down_alarm_name" {
  type = string
}

variable "frontend_cloudwatch_down_comparison_operator" {
  type = string
}

variable "frontend_cloudwatch_down_period" {
  type = number
}

variable "frontend_cloudwatch_down_threshold" {
  type = number
}


variable "backend_tg_port" {
  type = string
}

variable "backend_listener_port" {
  type = string
}

variable "backend_asg_policy_upscale" {
  type = string
}

variable "backend_asg_scaling_adjustment_upscale" {
  type = number
}

variable "backend_asg_adjustment_type_upscale" {
  type = string
}

variable "backend_asg_cooldown_upscale" {
  type = number
}

variable "backend_cloudwatch_up_alarm_name" {
  type = string
}

variable "backend_cloudwatch_up_comparison_operator" {
  type = string
}

variable "backend_cloudwatch_up_period" {
  type = number
}

variable "backend_cloudwatch_up_threshold" {
  type = number
}


variable "backend_asg_policy_downscale" {
  type = string
}

variable "backend_asg_scaling_adjustment_downscale" {
  type = number
}

variable "backend_asg_adjustment_type_downscale" {
  type = string
}

variable "backend_asg_cooldown_downscale" {
  type = number
}

variable "backend_cloudwatch_down_alarm_name" {
  type = string
}

variable "backend_cloudwatch_down_comparison_operator" {
  type = string
}

variable "backend_cloudwatch_down_period" {
  type = number
}

variable "backend_cloudwatch_down_threshold" {
  type = number
}

variable "frontend_asg_dynamic_scaling_enabled" {
  type = bool
}

variable "backend_asg_dynamic_scaling_enabled" {
  type = bool
}

#ecs variables
variable "ecs_enabled" {
  type = bool
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_task_defination_name" {
  type = string
}

variable "ecs_launch_type" {
  type = string
}

variable "ecs_network_mode" {
  type = string
}

variable "ecs_cpu_value" {
  type = number
}

variable "ecs_memory_value" {
  type = number
}

variable "ecs_service_name" {
  type = string
}

variable "desired_count_for_task_defination" {
  type = number
}

#eks variables
variable "eks_enabled" {
  type = bool
}

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

variable "node_instance_type" {
  type = string
}

variable "eks_capacity_type" {
  type = string
}

variable "eks_node_endpoint_private_access" {
  type = bool
}

variable "nat_gateway" {
  type = bool
}

variable "s3_bucket_name" {
  type = string
}