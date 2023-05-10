resource "aws_lb" "lb" {
  name               = var.lb_asg_name
  internal           = var.internal_lb_enabled
  load_balancer_type = "application"
  security_groups    = [ var.alb_asg_sg ]
  subnets            = var.lb_subnet
}

resource "aws_lb_target_group" "lb_tg" {
  name     = var.lb_tg_asg_name
  port     = var.tg_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}


