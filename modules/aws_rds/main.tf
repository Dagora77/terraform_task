resource "aws_db_subnet_group" "database-subnet-group" {
  name        = "php_app_vpc"
  subnet_ids  = [var.private_subnet_id_a, var.private_subnet_id_b]
  description = "Subnets for Database Instance"

  tags = {
    Name = "Database Subnets"
  }
}

resource "aws_db_instance" "PHP_app" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0.27"
  instance_class         = "db.t2.micro"
  identifier             = "php-app"
  port                   = "3306"
  username               = var.user
  password               = var.password
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.database-subnet-group.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}

resource "aws_security_group" "rds" {
  name        = "rds_sg"
  description = "rds_sg"
  vpc_id      = var.vpc_id
  tags = {
    Name = "RDS_security_group"
  }
  #tags        = merge(var.common_tags, { Name = "${var.common_tags["Project"]} Server IP" })

  ingress {
    description = "RDS from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}
