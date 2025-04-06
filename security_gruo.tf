resource "aws_security_group" "rds" {
  name        = "medusa-rds-sg"
  description = "Allow ECS access to RDS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"] # Use security_groups = [aws_security_group.ecs.id] for production
    description     = "Allow PostgreSQL access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "medusa-rds-sg"
  }
}


resource "aws_security_group" "ecs_service" {
  name        = "medusa-ecs-service-sg"
  description = "Allow ALB access to ECS service"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow traffic from ALB"
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "medusa-ecs-service-sg"
  }
}
  