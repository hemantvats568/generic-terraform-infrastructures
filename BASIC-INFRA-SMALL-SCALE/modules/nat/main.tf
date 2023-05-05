resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  depends_on = [var.gateway_id]
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet

  tags = {
    Name = "nat-gateway"
  }
}

resource "aws_route" "nat_route" {
  route_table_id         = var.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
