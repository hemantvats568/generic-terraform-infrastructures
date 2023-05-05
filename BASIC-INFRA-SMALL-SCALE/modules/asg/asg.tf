resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_launch_configuration" "launch_template" {
  name_prefix = "ec2-template"

  image_id = var.ami
  instance_type = var.instance_type
  key_name = aws_key_pair.key_pair.key_name

  security_groups             = [ var.security_group ]
  associate_public_ip_address = var.public_ip_enabled
  user_data                   = "#!/bin/bash\n\n sudo yum update -y \n sudo yum install -y httpd \n sudo systemctl start httpd \n sudo systemctl enable httpd \n echo '<h1>Hello World </h1>' > /var/www/html/index.html "

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