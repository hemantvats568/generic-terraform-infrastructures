output "subnet_id" {
  value       = aws_subnet.subnet[*].id
  description = "Public Subnet ID"
}
