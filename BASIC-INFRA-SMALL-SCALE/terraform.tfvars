# vpc variables
vpc_cidr_block = "10.0.0.0/16"
tenancy = "default"

#subnet variables
subnet_zones = {
  "public_ap_south_1a" = "ap-south-1a"
  "private_ap_south_1a" = "ap-south-1a"
  "lb_private_ap_south_1b" = "ap-south-1b"
  "lb_public_ap_south_1b" = "ap-south-1b"
  "public_nat_ap_south_1a" = "ap-south-1a"
}

subnet_names = [
  "public_ap_south_1a",
  "private_ap_south_1a",
  "lb_private_ap_south_1b",
  "lb_public_ap_south_1b",
  "public_nat_ap_south_1a"
]

subnet_type = {
  "public_ap_south_1a" = "public_rt"
  "private_ap_south_1a" = "private_rt"
  "lb_private_ap_south_1b" = "private_rt"
  "lb_public_ap_south_1b" = "public_rt"
  "public_nat_ap_south_1a" = "public_rt"
}

#s3 variables
bucket_name = "reference-project-aws-terraform-starter-cloudfront---sixteen"
s3_bucket_enabled = false
s3_versioning_enabled = "Enabled"
force_destroy = true

#cloudfront variables
frontend_cloudfront_enabled = false
default_root_object = "index.html"

#common variables for frontend asg & backend asg 
start_time_upscale = "T10:00:00Z"
end_time_upscale = "T10:15:00Z"
start_time_downscale = "T10:15:00Z"
end_time_downscale = "T10:25:00Z"

#frontend asg variables
frontend_ec2_enabled = true
frontend_asg_key_name = "terraform_asg_private_key_frontend"
frontend_asg_instance_type = "t2.micro"
frontend_asg_public_ip_enabled = true
frontend_asg_desired_capacity = 1
frontend_asg_max_size = 2
frontend_asg_min_size = 1
frontend_asg_schedule_action_name_upscale = "frontend_asg_schedule_upscale"
frontend_asg_schedule_action_name_downscale = "frontend_asg_schedule_downscale"
#frontend_asg_recurrence_schedule_upscale = "15 14 * * 1-5"
#frontend_asg_recurrence_schedule_downscale = "45 14 * * 1-5"
frontend_asg_scheduled_desired_capacity = 1
frontend_asg_scheduling_enabled = false
public_key_path = "public_key.pub"

frontend_asg_policy_upscale = "frontend_asg_policy_upscale"
frontend_asg_scaling_adjustment_upscale = 1
frontend_asg_adjustment_type_upscale =  "ChangeInCapacity"
frontend_asg_cooldown_upscale = 300
frontend_cloudwatch_up_alarm_name = "frontend_cpu_alarm_up"
frontend_cloudwatch_up_comparison_operator = "GreaterThanOrEqualToThreshold"
frontend_cloudwatch_up_period = 120
frontend_cloudwatch_up_threshold = 70

frontend_asg_policy_downscale = "frontend_asg_policy_downscale"
frontend_asg_scaling_adjustment_downscale = -1
frontend_asg_adjustment_type_downscale = "ChangeInCapacity"
frontend_asg_cooldown_downscale = 300
frontend_cloudwatch_down_alarm_name = "frontend_cpu_alarm_down"
frontend_cloudwatch_down_comparison_operator = "LessThanOrEqualToThreshold"
frontend_cloudwatch_down_period = 120
frontend_cloudwatch_down_threshold = 30

frontend_asg_dynamic_scaling_enabled = false

#backend asg variables
backend_ec2_enabled = false
backend_asg_key_name = "terraform_asg_private_key_backend"
backend_asg_instance_type = "t2.micro"
backend_asg_public_ip_enabled = false
backend_asg_desired_capacity = 1
backend_asg_max_size = 2
backend_asg_min_size = 1
backend_asg_schedule_action_name_upscale = "backend_asg_schedule_upscale"
backend_asg_schedule_action_name_downscale = "backend_asg_schedule_downscale"
#backend_asg_recurrence_schedule_upscale = "15 14 * * 1-5"
#backend_asg_recurrence_schedule_downscale = "45 14 * * 1-5"
backend_asg_scheduled_desired_capacity = 2
backend_asg_scheduling_enabled = false

backend_asg_policy_upscale = "backend_asg_policy_upscale"
backend_asg_scaling_adjustment_upscale = 1
backend_asg_adjustment_type_upscale = "ChangeInCapacity"
backend_asg_cooldown_upscale = 300
backend_cloudwatch_up_alarm_name = "backend_cpu_alarm_up"
backend_cloudwatch_up_comparison_operator = "GreaterThanOrEqualToThreshold"
backend_cloudwatch_up_period = 120
backend_cloudwatch_up_threshold = 70

backend_asg_policy_downscale = "backend_asg_policy_downscale"
backend_asg_scaling_adjustment_downscale = -1
backend_asg_adjustment_type_downscale = "ChangeInCapacity"
backend_asg_cooldown_downscale = 300
backend_cloudwatch_down_alarm_name = "backend_cpu_alarm_down"
backend_cloudwatch_down_comparison_operator = "LessThanOrEqualToThreshold"
backend_cloudwatch_down_period = 120
backend_cloudwatch_down_threshold = 30

backend_asg_dynamic_scaling_enabled = false

#asg lb for backend. For frontend it is always enabled
internal_lb_enabled = false
backend_lb_asg_name = "backend-lb"
backend_lb_tg_asg_name = "backend-lb-tg"
frontend_lb_asg_name = "frontend-lb"
frontend_lb_tg_asg_name = "frontend-lb-tg"

#rds variables
rds_enabled = false
rds_instance_name = "mydb"
rds_instance_class = "db.t2.micro"
rds_publicly_accessible_enabled = false
allocated_db_storage = 10
db_engine_name = "mysql"
db_engine_version = 5.7
db_port = 3306
skip_db_final_snapshot = true

#iam variables
s3_bucket_name = "beehyvstatebucketforinternalproject"

#ecs variables
ecs_enabled = false
ecs_cluster_name = "ecs-cluster-1"
ecs_task_defination_name = "ecs-cluster-task-defination"
desired_count_for_task_defination = 1
ecs_launch_type = "FARGATE" // "FARGATE/EC2"
ecs_network_mode = "awsvpc"
ecs_cpu_value = 1024
ecs_memory_value = 4096
ecs_service_name = "ecs-first-task-defination-service"

#eks variables
eks_enabled = false
eks_cluster_name = "new_eks_cluster"
eks_node_group_name = "eks_node_group"
eks_desired_num_of_nodes = 1
eks_max_num_of_nodes = 1
eks_min_num_of_nodes = 1
node_instance_type = "t2.small"
eks_capacity_type = "ON_DEMAND"
eks_node_endpoint_private_access = true

# nat variables
nat_gateway = false
