
resource "aws_db_instance" "medusa" {
  identifier             = "medusa-db"
  engine                 = "postgres"
  engine_version         = "17.4"                      # Optional: Specify version
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = var.db_user
  password               = var.db_password
  db_name                = "medusadb"
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.medusa.name
  skip_final_snapshot    = true                         # Optional: for quicker testing

  tags = {
    Name = "medusa-db"
  }
}

resource "aws_db_subnet_group" "medusa" {
  name       = "medusa-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "medusa-db-subnet-group"
  }
}
