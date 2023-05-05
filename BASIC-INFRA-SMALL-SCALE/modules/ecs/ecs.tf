resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name
}

resource "aws_ecs_task_definition" "ecs_task_defination" {
  family                   = var.ecs_task_defination_name
  container_definitions    = file("${path.module}/task_defination/service.json")
  requires_compatibilities = ["${var.ecs_launch_type}"]
  network_mode             = var.ecs_network_mode
  cpu                      = var.ecs_cpu_value
  memory                   = var.ecs_memory_value
}

resource "aws_ecs_service" "ecs_service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_defination.arn
  desired_count   = var.desired_count_for_task_defination
  launch_type     = "${var.ecs_launch_type}"
}
