module "ecr" {
  source = "../../modules/ecr"
  p_name = var.p_name
  aws_region = var.aws_region
  account_id = data.aws_caller_identity.current.account_id
  aws_cli_profile = var.aws_cli_profile
}

module "lambda" {
  source = "../../modules/lambda"
  p_name = var.p_name
  docker_image_push_obj = module.ecr.null_resource_docker_image_push
  api-gateway-image-uri = module.ecr.api_gateway_ecr_image_url
  reservation-image-uri = module.ecr.reservation_ecr_image_url
  availability-image-uri = module.ecr.availability_ecr_image_url
  aws_apigatewayv2_api_execution_arn = module.api_gateway.aws_apigatewayv2_api_execution_arn
  aws_dynamodb_table_court_reservations_name = module.dynamodb.aws_dynamodb_table_court_reservations_name
  aws_dynamodb_table_court_availability_reservations_arn = module.dynamodb.aws_dynamodb_table_court_availability_reservations_arn
}

module "api_gateway" {
  source = "../../modules/api_gateway"
  p_name = var.p_name
  aws_lambda_function_invoke_arn = module.lambda.aws_lambda_function_invoke_arn
  lambda_function_court_availability_invoke_arn = module.lambda.lambda_function_court_availability_invoke_arn
  lambda_function_court_reservation_invoke_arn = module.lambda.lambda_function_court_reservation_invoke_arn
}

module "weather_service" {
  source=  "../../modules/weather_service"
  p_name = var.p_name
  lambda_iam_role_arn = module.lambda.aws_iam_role_lambda_exec_role_arn
  aws_cli_profile = var.aws_cli_profile
  aws_region = var.aws_region
  account_id = data.aws_caller_identity.current.account_id
  aws_apigatewayv2_api_execution_arn = module.api_gateway.aws_apigatewayv2_api_execution_arn
  aws_apigatewayv2_api_main_id = module.api_gateway.api_id
}

module "dynamodb" {
  source = "../../modules/dynamodb_table"
  p_name = var.p_name
  aws_cli_profile = var.aws_cli_profile
  region = var.aws_region
}