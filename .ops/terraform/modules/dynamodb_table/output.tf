output "aws_dynamodb_table_court_reservations_name" {
  value = aws_dynamodb_table.court_availability_reservations.name
}

output "aws_dynamodb_table_court_availability_reservations_arn" {
  value = aws_dynamodb_table.court_availability_reservations.arn
}