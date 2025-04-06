resource "aws_ecs_cluster" "medusa" {
  name = "medusa-cluster"
}

resource "aws_ecs_task_definition" "medusa" {
  family                   = "medusa-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn      = aws_iam_role.ecs_task.arn


  network_mode             = "awsvpc"
  

  container_definitions = jsonencode([
    {
      name  = "medusa"
      image = "${aws_ecr_repository.medusa.repository_url}:latest"
      portMappings = [
        {
          containerPort = 9000
          hostPort      = 9000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "DATABASE_URL"
          value = "postgres://${var.db_user}:${var.db_password}@${aws_db_instance.medusa.address}:${aws_db_instance.medusa.port}/medusadb"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "medusa" {
  name            = "medusa-service"
  cluster         = aws_ecs_cluster.medusa.id
  task_definition = aws_ecs_task_definition.medusa.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.medusa.arn
    container_name   = "medusa"
    container_port   = 9000
  }

  depends_on = [aws_lb_listener.http]
}
resource "aws_ecr_repository" "medusa" {
  name                 = "medusa"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "medusa-ecr-repo"
  }
}

