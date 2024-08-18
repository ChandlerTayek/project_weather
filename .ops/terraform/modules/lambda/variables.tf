variable "p_name" {
  type = string
}

variable "api-gateway-image-uri" {
  type = string
}

variable "reservation-image-uri" {
  type = string
}

variable "availability-image-uri" {
  type = string
}

variable "docker_image_push_obj" {
  
}

variable "aws_apigatewayv2_api_execution_arn" {
  type = any
}

variable "aws_dynamodb_table_court_reservations_name" {
  type = string
}

variable "aws_dynamodb_table_court_availability_reservations_arn" {
  type = string
}