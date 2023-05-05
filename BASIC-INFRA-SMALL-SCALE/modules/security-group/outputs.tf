output "private_sg" {
  value = aws_security_group.private_sg.id
}

output "public_sg" {
  value = aws_security_group.public_sg.id
}

output "private_alb_asg_sg" {
  value = aws_security_group.private_alb_sg.id
}

output "public_alb_asg_sg" {
  value = aws_security_group.public_alb_sg.id
}