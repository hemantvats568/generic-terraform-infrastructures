resource "aws_internet_gateway" "new_igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "IGW"
  }
}
