resource "aws_db_subnet_group" "rds" {
  name       = "rds-github-monitoring-dashboard"
  subnet_ids = module.vpc.public_subnets

  tags = local.tags
}

resource "aws_security_group" "rds" {
  name   = "rds-github-monitoring-dashboard"
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
  name   = "rds-github-monitoring-dashboard"
  family = "postgres13"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  tags = local.tags
}

resource "aws_db_instance" "rds" {
  identifier             = "rds-github-monitoring-dashboard"
  instance_class         = "db.t3.micro"
  allocated_storage      = 100
  engine                 = "postgres"
  engine_version         = "13.10"

  username               = "read_write"
  password               = var.rds_rw_password

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.rds.name
  publicly_accessible    = true
  skip_final_snapshot    = true

  tags = local.tags

  provisioner "local-exec" {
    command = <<-EOT
      for file in ${path.module}/schemas/*.sql; do
        export PASSWORD=${var.rds_ro_password};
        path=$(realpath $file);
        command=$(envsubst -i $path);
        PGPASSWORD=${self.password} psql --host=${self.address} --port=${self.port} --user=${self.username} --dbname=postgres --command "$command";
      done
    EOT
    interpreter = [ "/usr/bin/env", "bash", "-c" ]
  }
}
