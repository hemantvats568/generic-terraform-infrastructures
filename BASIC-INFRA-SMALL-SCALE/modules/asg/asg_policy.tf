resource "aws_autoscaling_policy" "policy_upscale" {
  count = var.asg_dynamic_scaling_enabled ? 1 : 0
  name = var.asg_policy_upscale
  scaling_adjustment = var.asg_scaling_adjustment_upscale
  adjustment_type = var.asg_adjustment_type_upscale
  cooldown = var.asg_cooldown_upscale
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}
resource "aws_cloudwatch_metric_alarm" "cpu_alarm_up" {
  count = var.asg_dynamic_scaling_enabled ? 1 : 0
  alarm_name = var.cloudwatch_up_alarm_name
  comparison_operator = var.cloudwatch_up_comparison_operator
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = var.cloudwatch_up_period
  statistic = "Average"
  threshold = var.cloudwatch_up_threshold
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }
  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions = [ "${aws_autoscaling_policy.policy_upscale[0].arn}" ]
}
resource "aws_autoscaling_policy" "policy_downscale" {
  count = var.asg_dynamic_scaling_enabled ? 1 : 0
  name = var.asg_policy_downscale
  scaling_adjustment = var.asg_scaling_adjustment_downscale
  adjustment_type = var.asg_adjustment_type_downscale
  cooldown = var.asg_cooldown_downscale
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}
resource "aws_cloudwatch_metric_alarm" "cpu_alarm_down" {
  count = var.asg_dynamic_scaling_enabled ? 1 : 0
  alarm_name = var.cloudwatch_down_alarm_name
  comparison_operator =  var.cloudwatch_down_comparison_operator
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = var.cloudwatch_down_period
  statistic = "Average"
  threshold = var.cloudwatch_down_threshold
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }
  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions = [ "${aws_autoscaling_policy.policy_downscale[0].arn}" ]
}
