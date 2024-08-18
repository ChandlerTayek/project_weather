output "api_endpoint" {
  value = "https://${module.api_gateway.api_id}.execute-api.${var.aws_region}.amazonaws.com/dev/"
}