/*output "public_subnet_a_id" {
  value = data.aws_subnet.public_subnet_a.id
}
*/
output "aws_db_php" {
  value = aws_db_instance.PHP_app.id
}


output "aws_db_php_endpoint" {
  value = aws_db_instance.PHP_app.address
}
