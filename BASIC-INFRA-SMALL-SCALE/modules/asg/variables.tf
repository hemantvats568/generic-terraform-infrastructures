variable "key_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "security_group" {
    type = string
}

variable "public_ip_enabled" {
    type = bool
}

variable "desired_capacity" {
    type = number
}

variable "max_size" {
    type = number
}

variable "min_size" {
    type = number
}

variable "subnet" {
    type = list
}

variable "asg_name" {
    type = string
}

variable "asg_schedule_action_name_upscale" {
  type = string
}

variable "asg_schedule_action_name_downscale" {
  type = string
}

#variable "asg_recurrence_schedule_upscale" {
#  type = string
#}
#
#variable "asg_recurrence_schedule_downscale" {
#  type = string
#}

variable "asg_scheduled_desired_capacity" {
  type = number
}

variable "asg_scheduling_enabled" {
  type  = bool
  default = false
}

variable "asg_schedule_start_time_upscale" {
  type = string
}

variable "asg_schedule_end_time_upscale" {
  type = string
}

variable "asg_schedule_start_time_downscale" {
  type = string
}

variable "asg_schedule_end_time_downscale" {
  type = string
}

variable "internal_lb_enabled" {
  type = bool
}

variable "vpc_id" {
  type = string
}

variable "lb_subnet" {
  type = list
}

variable "lb_tg_asg_name" {
  type = string
}

variable "lb_asg_name" {
  type = string
}

variable "alb_asg_sg" {
  type = string
}

variable "asg_policy_upscale" {
  type = string
}

variable "asg_scaling_adjustment_upscale" {
  type = number
}

variable "asg_adjustment_type_upscale" {
  type = string
}

variable "asg_cooldown_upscale" {
  type = number
}

variable "cloudwatch_up_alarm_name" {
  type = string
}

variable "cloudwatch_up_comparison_operator" {
  type = string
}

variable "cloudwatch_up_period" {
  type = number
}

variable "cloudwatch_up_threshold" {
  type = number
}

variable "asg_policy_downscale" {
  type = string
}

variable "asg_scaling_adjustment_downscale" {
  type = number
}

variable "asg_adjustment_type_downscale" {
  type = string
}

variable "asg_cooldown_downscale" {
  type = number
}

variable "cloudwatch_down_alarm_name" {
  type = string
}

variable "cloudwatch_down_comparison_operator" {
  type = string
}

variable "cloudwatch_down_period" {
  type = number
}

variable "cloudwatch_down_threshold" {
  type = number
}

variable "asg_dynamic_scaling_enabled" {
  type = bool
}

variable "public_key_path" {
  type = string
}

variable "s3_iam_profile_name" {
  type = string
}