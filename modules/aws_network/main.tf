resource "aws_vpc" "PHP_app" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}_PHP_app_vpc"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.PHP_app.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "Public_A"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.PHP_app.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "Public_B"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.PHP_app.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "us-east-2a"


  tags = {
    Name = "Private_A"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.PHP_app.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "Private_B"
  }
}

resource "aws_route_table" "PHP_app_public_a" {
  vpc_id = aws_vpc.PHP_app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.PHP_app.id
  }

  tags = {
    Name = "Public_A"
  }
}

resource "aws_route_table" "PHP_app_private_a" {
  vpc_id = aws_vpc.PHP_app.id

  tags = {
    Name = "Private_A"
  }
}

resource "aws_route_table_association" "PHP_app_public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.PHP_app_public_a.id
}

resource "aws_route_table_association" "PHP_app_private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.PHP_app_private_a.id
}

resource "aws_route_table_association" "PHP_app_public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.PHP_app_public_a.id
}

resource "aws_route_table_association" "PHP_app_private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.PHP_app_private_a.id
}

resource "aws_security_group" "my_webserver" {
  name        = "PHP_app"
  description = "PHP_app"
  vpc_id      = aws_vpc.PHP_app.id
  tags = {
    Name = "PHP_app"
  }
  #tags        = merge(var.common_tags, { Name = "${var.common_tags["Project"]} Server IP" })

  dynamic "ingress" {
    for_each = var.allow_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["77.87.158.69/32"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

/*resource "aws_security_group" "bastion_host" {
  name        = "PHP_app_bastion_host"
  description = "PHP_app_bastion_host"
  vpc_id      = aws_vpc.PHP_app.id
  tags = {
    Name = "PHP_app_bastion_host"
  }
  #tags        = merge(var.common_tags, { Name = "${var.common_tags["Project"]} Server IP" })

  dynamic "ingress" {
    for_each = var.allow_ports_bastion
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
*/

resource "aws_internet_gateway" "PHP_app" {
  vpc_id = aws_vpc.PHP_app.id

  tags = {
    Name = "PHP_app"
  }
}
