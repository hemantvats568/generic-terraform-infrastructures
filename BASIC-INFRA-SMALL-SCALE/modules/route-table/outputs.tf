output "route_table_id" {
  value = [aws_route_table.private_rt.id, aws_route_table.public_rt.id]
}
