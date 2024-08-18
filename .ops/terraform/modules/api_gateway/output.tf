output "api_id" {
  value = aws_apigatewayv2_api.main.id
}

output "aws_apigatewayv2_api_execution_arn" {
  value = aws_apigatewayv2_api.main.execution_arn
}