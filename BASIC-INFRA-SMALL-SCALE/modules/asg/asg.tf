resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = file("${var.public_key_path}")
}

data "aws_ami" "amazon_linux_2_latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"]
}


resource "aws_launch_configuration" "launch_template" {
  name_prefix = "ec2-template"

  image_id = "${data.aws_ami.amazon_linux_2_latest.id}"
  instance_type = var.instance_type
  key_name = aws_key_pair.key_pair.key_name
  iam_instance_profile        = var.s3_iam_profile_name
  security_groups             = [ var.security_group ]
  associate_public_ip_address = var.public_ip_enabled
  user_data                   = file("${path.module}/${var.user_data}")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name               = var.asg_name
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  force_delete       = true
  health_check_type  = "ELB"
  launch_configuration = aws_launch_configuration.launch_template.name
  vpc_zone_identifier  = var.subnet
  target_group_arns = [aws_lb_target_group.lb_tg.arn]
}

resource "aws_autoscaling_schedule" "asg_schedule_upscale" {
  count                  = var.asg_scheduling_enabled ? 1 :0
  scheduled_action_name  = var.asg_schedule_action_name_upscale
  autoscaling_group_name = aws_autoscaling_group.asg.name
  start_time     = var.asg_schedule_start_time_upscale
  end_time       = var.asg_schedule_end_time_upscale
  time_zone              = "Asia/Kolkata"
  #  recurrence             = var.asg_recurrence_schedule_upscale
  desired_capacity       = var.asg_scheduled_desired_capacity
  max_size               = var.max_size
  min_size               = var.min_size
}

resource "aws_autoscaling_schedule" "asg_schedule_downscale" {
  count                  = var.asg_scheduling_enabled ? 1 :0
  scheduled_action_name  = var.asg_schedule_action_name_downscale
  autoscaling_group_name = aws_autoscaling_group.asg.name
  start_time             = var.asg_schedule_start_time_downscale
  end_time               = var.asg_schedule_end_time_downscale
  time_zone              = "Asia/Kolkata"
  #  recurrence             = var.asg_recurrence_schedule_downscale
  desired_capacity       = var.desired_capacity
  max_size               = var.max_size
  min_size               = var.min_size
}