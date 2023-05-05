resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Public Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    security_groups = [aws_security_group.public_alb_sg.id]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "TCP"
    security_groups = [aws_security_group.public_alb_sg.id]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "Private Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH to private instance from inside VPC"
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    cidr_blocks     = ["10.0.0.0/16"]
  }
  ingress {
    from_port = 80
    protocol  = "TCP"
    to_port   = 80
    security_groups = [aws_security_group.private_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "public_alb_sg" {
  name = "public_alb_asg_sg"
  vpc_id      = var.vpc_id
  description = "Public ALB Security Group"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_alb_sg" {
  name = "private_alb_asg_sg"
  vpc_id      = var.vpc_id
  description = "Private ALB Security Group"

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    security_groups = [aws_security_group.public_alb_sg.id,aws_security_group.public_sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}