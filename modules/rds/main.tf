resource "aws_security_group" "database" {
  name        = "${var.env}-postgres"
  description = "Allow PostgreSQL connections from the configured client subnet."
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from the allowed client subnet."
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.allowed_client_cidr]
  }

  tags = {
    Name = "${var.env}-postgres"
  }
}

resource "aws_db_subnet_group" "database" {
  name        = "${var.env}-postgres"
  description = "Private subnets for the ${var.env} PostgreSQL database."
  subnet_ids  = var.private_subnet_ids

  tags = {
    Name = "${var.env}-postgres"
  }
}

resource "aws_db_instance" "database" {
  identifier                          = "${var.env}-postgres"
  engine                              = "postgres"
  engine_version                      = var.engine_version
  instance_class                      = var.instance_class
  allocated_storage                   = var.allocated_storage
  storage_type                        = var.storage_type
  storage_encrypted                   = true
  db_name                             = "postgres"
  username                            = var.master_username
  manage_master_user_password         = var.manage_master_password
  iam_database_authentication_enabled = true
  availability_zone                   = var.availability_zone
  multi_az                            = false
  publicly_accessible                 = false
  db_subnet_group_name                = aws_db_subnet_group.database.name
  vpc_security_group_ids              = [aws_security_group.database.id]
  backup_retention_period             = 1
  deletion_protection                 = false
  skip_final_snapshot                 = true
  copy_tags_to_snapshot               = true

  tags = {
    Name = "${var.env}-postgres"
  }
}
