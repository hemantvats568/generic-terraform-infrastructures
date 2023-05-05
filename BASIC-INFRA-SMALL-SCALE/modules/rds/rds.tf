resource "aws_db_instance" "rds_instance" {
  db_name             = var.db_name
  engine              = var.db_engine_name
  engine_version      = var.db_engine_version
  port                = var.db_port
  username            = var.db_username
  password            = var.db_password
  instance_class      = var.rds_instance_class
  allocated_storage   = var.allocated_db_storage
  publicly_accessible = var.rds_publicly_accessible_enabled
  skip_final_snapshot = var.skip_db_final_snapshot
}