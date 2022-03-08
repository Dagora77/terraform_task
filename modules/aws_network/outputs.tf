
output "vpc_id" {
  value = aws_vpc.PHP_app.id
}

output "public_subnet_id_a" {
  value = aws_subnet.public_a.id
}

output "public_subnet_id_b" {
  value = aws_subnet.public_b.id
}

output "private_subnet_id_a" {
  value = aws_subnet.private_a.id
}

output "private_subnet_id_b" {
  value = aws_subnet.private_b.id
}

output "env_security_group" {
  value = aws_security_group.my_webserver.id
}
