output "aws_lambda_function_invoke_arn" {
  value = aws_lambda_function.api-gateway.invoke_arn
}

output "lambda_function_court_availability_invoke_arn" {
  value = aws_lambda_function.court_availability_lambda.invoke_arn
}

output "lambda_function_court_reservation_invoke_arn" {
  value = aws_lambda_function.court_reservation_lambda.invoke_arn
}