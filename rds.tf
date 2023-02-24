resource "aws_db_subnet_group" "rds" {
  name       = "rds-tf-aws-gh-observability"
  subnet_ids = module.vpc.public_subnets

  tags = local.tags
}

resource "aws_security_group" "rds" {
  name   = "rds-tf-aws-gh-observability"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_db_parameter_group" "rds" {
  name   = "rds-tf-aws-gh-observability"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  tags = local.tags
}

resource "aws_db_instance" "rds" {
  identifier             = "rds-tf-aws-gh-observability"
  instance_class         = "db.t3.micro"
  allocated_storage      = 100
  engine                 = "postgres"
  engine_version         = "13.7"

  username               = var.rds_username
  password               = var.rds_password

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.rds.name
  publicly_accessible    = true
  skip_final_snapshot    = true

  tags = local.tags

  provisioner "local-exec" {
    command = "PGPASSWORD=${self.password} psql --host=${self.address} --port=${self.port} --user=${self.username} --dbname=postgres < ${path.module}/schemas/*.sql"
  }
}
