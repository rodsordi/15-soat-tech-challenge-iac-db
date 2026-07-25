# --- Random Password Generation ---
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# --- AWS Secrets Manager for DB Credentials ---
resource "aws_secretsmanager_secret" "db_secret" {
  name                    = "garage-db-credentials"
  description             = "Managed PostgreSQL credentials for garage API"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = "postgres"
    host     = aws_db_instance.postgres.address
    port     = aws_db_instance.postgres.port
    dbname   = var.db_name
  })
}

# --- Security Group ---
resource "aws_security_group" "rds_sg" {
  name        = "garage-rds-sg"
  description = "Security group for RDS PostgreSQL database"

  ingress {
    description = "Allow PostgreSQL access from EKS VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- RDS DB Instance ---
resource "aws_db_instance" "postgres" {
  identifier                          = "garage-postgres-db"
  allocated_storage                   = 20
  storage_type                        = "gp2"
  engine                              = "postgres"
  engine_version                      = "15.4"
  instance_class                      = var.instance_class
  db_name                             = var.db_name
  username                            = var.db_username
  password                            = random_password.db_password.result
  skip_final_snapshot                 = true
  publicly_accessible                 = false
  iam_database_authentication_enabled = true
  vpc_security_group_ids              = [aws_security_group.rds_sg.id]

  tags = {
    Name = "garage-postgres-db"
  }
}
