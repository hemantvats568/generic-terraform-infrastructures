module "vpc" {
  source = "./modules/vpc"

  cidr_block    = var.vpc_cidr_block
  tenancy       = var.tenancy
}

module "subnets" {
  depends_on          = [module.rt]
  count               = length(var.subnet_names)
  source              = "./modules/subnet"
  vpc_id              = module.vpc.id
  subnet_cidr         = cidrsubnet(var.vpc_cidr_block, 8, count.index+1)
  availability_zone   = var.subnet_zones[var.subnet_names[count.index]]
  subnet_name         = var.subnet_names[count.index]
  route_table_id      = var.subnet_type[var.subnet_names[count.index]]=="private_rt" ? module.rt.route_table_id[0] : module.rt.route_table_id[1]
}

module "internet_gateway" {
  source = "./modules/internet-gateway"

  vpc_id = module.vpc.id
}

module "nat_gateway" {
  count  = var.nat_gateway || var.eks_enabled ? 1 : 0
  source = "./modules/nat"
  public_subnet = module.subnets[4].subnet_id[0]
  gateway_id    = module.internet_gateway.id
  route_table_id = module.rt.route_table_id[0]
}

module "rt" {
  source = "./modules/route-table"

  vpc_id         = module.vpc.id
  gateway_id     = module.internet_gateway.id
}

module "s3" {
  source = "./modules/s3"

  count                     = var.s3_bucket_enabled ? 1 : 0
  bucket_name               = var.bucket_name
  force_destroy             = var.force_destroy
  s3_versioning_enabled     = var.s3_versioning_enabled
}

#module "cloudfront" {
#  count     = var.frontend_cloudfront_enabled ? 1 :0
#  depends_on = [module.s3]
#  source = "./modules/cloudfront"
#
#  regional_bucket_domain_name = module.s3.regional_bucket_domain_name
#  default_root_object = var.default_root_object
#  cloudfront_origin_bucket_arn = module.s3.arn
#  cloudfront_origin_bucket = module.s3.id
#}

module "frontend_asg" {
  depends_on                      = [module.security-group, module.iam]
  count                           = var.frontend_ec2_enabled ? 1 : 0
  source                          = "./modules/asg"
  asg_name                        = "frontend_asg"
  key_name                        = var.frontend_asg_key_name
  instance_type                   = var.frontend_asg_instance_type
  security_group                  = module.security-group[0].public_sg
  public_ip_enabled               = var.frontend_asg_public_ip_enabled
  desired_capacity                = var.frontend_asg_desired_capacity
  max_size                        = var.frontend_asg_max_size
  min_size                        = var.frontend_asg_min_size
  subnet                          = [module.subnets[0].subnet_id[0]]
  asg_schedule_action_name_upscale        = var.frontend_asg_schedule_action_name_upscale
  asg_schedule_action_name_downscale      = var.frontend_asg_schedule_action_name_downscale
#  asg_recurrence_schedule_upscale         = var.frontend_asg_recurrence_schedule_upscale
#  asg_recurrence_schedule_downscale       = var.frontend_asg_recurrence_schedule_downscale
  asg_scheduled_desired_capacity  = var.frontend_asg_scheduled_desired_capacity
  asg_scheduling_enabled          = var.frontend_asg_scheduling_enabled
  asg_schedule_start_time_upscale         = "${formatdate("YYYY-MM-DD",timestamp())}${var.start_time_upscale}"
  asg_schedule_end_time_upscale           = "${formatdate("YYYY-MM-DD",timestamp())}${var.end_time_upscale}"
  asg_schedule_start_time_downscale         = "${formatdate("YYYY-MM-DD",timestamp())}${var.start_time_downscale}"
  asg_schedule_end_time_downscale           = "${formatdate("YYYY-MM-DD",timestamp())}${var.end_time_downscale}"
  internal_lb_enabled             = var.internal_lb_enabled
  vpc_id                          = module.vpc.id
  lb_subnet                       = [module.subnets[0].subnet_id[0],module.subnets[3].subnet_id[0]]
  lb_asg_name                     = var.frontend_lb_asg_name
  lb_tg_asg_name                  = var.frontend_lb_tg_asg_name
  alb_asg_sg                      = module.security-group[0].public_alb_asg_sg
  asg_policy_upscale              = var.frontend_asg_policy_upscale
  asg_scaling_adjustment_upscale  = var.frontend_asg_scaling_adjustment_upscale
  asg_adjustment_type_upscale     = var.frontend_asg_adjustment_type_upscale
  asg_cooldown_upscale            = var.frontend_asg_cooldown_upscale
  cloudwatch_up_alarm_name        = var.frontend_cloudwatch_up_alarm_name
  cloudwatch_up_comparison_operator = var.frontend_cloudwatch_up_comparison_operator
  cloudwatch_up_period            = var.frontend_cloudwatch_up_period
  cloudwatch_up_threshold         = var.frontend_cloudwatch_up_threshold

  asg_policy_downscale              = var.frontend_asg_policy_downscale
  asg_scaling_adjustment_downscale  = var.frontend_asg_scaling_adjustment_downscale
  asg_adjustment_type_downscale     = var.frontend_asg_adjustment_type_downscale
  asg_cooldown_downscale            = var.frontend_asg_cooldown_downscale
  cloudwatch_down_alarm_name        = var.frontend_cloudwatch_down_alarm_name
  cloudwatch_down_comparison_operator = var.frontend_cloudwatch_down_comparison_operator
  cloudwatch_down_period            = var.frontend_cloudwatch_down_period
  cloudwatch_down_threshold         = var.frontend_cloudwatch_down_threshold
  asg_dynamic_scaling_enabled       = var.frontend_asg_dynamic_scaling_enabled
  public_key_path                   = var.public_key_path
  s3_iam_profile_name               = module.iam.aws_iam_instance_profile
}

module "iam" {
  source = "./modules/iam"
  s3_bucket_name = var.s3_bucket_name
}

module "backend_asg" {
  depends_on                              = [module.security-group, module.iam]
  count                                   = var.backend_ec2_enabled ? 1 : 0
  source                                  = "./modules/asg"
  asg_name                                = "backend_asg"
  key_name                                = var.backend_asg_key_name
  instance_type                           = var.backend_asg_instance_type
  security_group                          = module.security-group[0].private_sg
  public_ip_enabled                       = var.backend_asg_public_ip_enabled
  desired_capacity                        = var.backend_asg_desired_capacity
  max_size                                = var.backend_asg_max_size
  min_size                                = var.backend_asg_min_size
  subnet                                  = [module.subnets[1].subnet_id[0]]
  asg_schedule_action_name_upscale        = var.backend_asg_schedule_action_name_upscale
  asg_schedule_action_name_downscale      = var.backend_asg_schedule_action_name_downscale
#  asg_recurrence_schedule_upscale         = var.backend_asg_recurrence_schedule_upscale
#  asg_recurrence_schedule_downscale       = var.backend_asg_recurrence_schedule_downscale
  asg_scheduled_desired_capacity          = var.backend_asg_scheduled_desired_capacity
  asg_scheduling_enabled                  = var.backend_asg_scheduling_enabled
  # Time should be given in the utc time zone later it will be converted to Asia/Kolkata
  asg_schedule_start_time_upscale         = "${formatdate("YYYY-MM-DD",timestamp())}${var.start_time_upscale}"
  asg_schedule_end_time_upscale           = "${formatdate("YYYY-MM-DD",timestamp())}${var.end_time_upscale}"
  asg_schedule_start_time_downscale         = "${formatdate("YYYY-MM-DD",timestamp())}${var.start_time_downscale}"
  asg_schedule_end_time_downscale           = "${formatdate("YYYY-MM-DD",timestamp())}${var.end_time_downscale}"
  alb_asg_sg                              = module.security-group[0].private_alb_asg_sg
  internal_lb_enabled                     = true
  vpc_id                                  = module.vpc.id
  lb_subnet                               = [module.subnets[1].subnet_id[0],module.subnets[2].subnet_id[0]]
  lb_asg_name                             = var.backend_lb_asg_name
  lb_tg_asg_name                          = var.backend_lb_tg_asg_name
  asg_policy_upscale              = var.backend_asg_policy_upscale
  asg_scaling_adjustment_upscale  = var.backend_asg_scaling_adjustment_upscale
  asg_adjustment_type_upscale     = var.backend_asg_adjustment_type_upscale
  asg_cooldown_upscale            = var.backend_asg_cooldown_upscale
  cloudwatch_up_alarm_name        = var.backend_cloudwatch_up_alarm_name
  cloudwatch_up_comparison_operator = var.backend_cloudwatch_up_comparison_operator
  cloudwatch_up_period            = var.backend_cloudwatch_up_period
  cloudwatch_up_threshold         = var.backend_cloudwatch_up_threshold

  asg_policy_downscale              = var.backend_asg_policy_downscale
  asg_scaling_adjustment_downscale  = var.backend_asg_scaling_adjustment_downscale
  asg_adjustment_type_downscale     = var.backend_asg_adjustment_type_downscale
  asg_cooldown_downscale            = var.backend_asg_cooldown_downscale
  cloudwatch_down_alarm_name        = var.backend_cloudwatch_down_alarm_name
  cloudwatch_down_comparison_operator = var.backend_cloudwatch_down_comparison_operator
  cloudwatch_down_period            = var.backend_cloudwatch_down_period
  cloudwatch_down_threshold         = var.backend_cloudwatch_down_threshold
  asg_dynamic_scaling_enabled       = var.backend_asg_dynamic_scaling_enabled
  public_key_path                   = var.public_key_path
  s3_iam_profile_name               = module.iam.aws_iam_instance_profile
}

module "security-group" {
  count  = var.eks_enabled ? 0 : 1
  source = "./modules/security-group"
  vpc_id = module.vpc.id
}

module "rds" {
  count                               = var.rds_enabled ? 1 : 0
  source                              = "./modules/rds"
  db_name                             = var.rds_instance_name
  db_username                         = var.db_username
  db_password                         = var.db_password
  db_port                                = var.db_port
  rds_publicly_accessible_enabled     = var.rds_publicly_accessible_enabled
  rds_instance_class                  = var.rds_instance_class
  allocated_db_storage                = var.allocated_db_storage
  db_engine_name                      = var.db_engine_name
  db_engine_version                   = var.db_engine_version
  skip_db_final_snapshot              = var.skip_db_final_snapshot
}

module "ecs" {
  count                               = var.ecs_enabled ? 1 : 0
  source                              = "./modules/ecs"
  ecs_cluster_name                    = var.ecs_cluster_name
  ecs_task_defination_name            = var.ecs_task_defination_name
  ecs_launch_type                     = var.ecs_launch_type
  ecs_network_mode                    = var.ecs_network_mode
  ecs_cpu_value                       = var.ecs_cpu_value
  ecs_memory_value                    = var.ecs_memory_value
  ecs_service_name                    = var.ecs_service_name
  desired_count_for_task_defination   = var.desired_count_for_task_defination
}

module "eks" {
  count                               = var.eks_enabled ? 1 : 0
  source                              = "./modules/eks"
#  eks_launch_type                     = var.eks_launch_type
  eks_cluster_name                    = var.eks_cluster_name
  eks_node_group_name                 = var.eks_node_group_name
  eks_desired_num_of_nodes            = var.eks_desired_num_of_nodes
  eks_max_num_of_nodes                = var.eks_max_num_of_nodes
  eks_min_num_of_nodes                = var.eks_min_num_of_nodes
  subnet_ids                          = [module.subnets[1].subnet_id[0],module.subnets[2].subnet_id[0]]
  node_instance_type                  = var.node_instance_type
  eks_capacity_type                   = var.eks_capacity_type
  vpc_id                              = module.vpc.id
  eks_node_endpoint_private_access    = var.eks_node_endpoint_private_access
}
