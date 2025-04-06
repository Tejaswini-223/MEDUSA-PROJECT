output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnets"
  value       = module.vpc.public_subnets
}

output "rds_endpoint" {
  description = "RDS endpoint address"
  value       = aws_db_instance.medusa.address
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.medusa.dns_name
}

output "ecr_repo_url" {
  description = "ECR repository URL for the Medusa Docker image"
  value       = aws_ecr_repository.medusa.repository_url
}


