# Security group for the Application Load Balancer
resource "aws_security_group" "alb" {
  name        = "medusa-alb-sg"
  description = "Allow HTTP inbound traffic for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "medusa-alb-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "medusa" {
  name               = "medusa-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb.id]

  enable_deletion_protection = false

  tags = {
    Name = "medusa-alb"
  }
}

# Target Group for ECS
resource "aws_lb_target_group" "medusa" {
  name        = "medusa-tg"
  port        = 9000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "medusa-tg"
  }
}

# Listener to route HTTP traffic to ECS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.medusa.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.medusa.arn
  }
}

