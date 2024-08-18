resource "aws_apigatewayv2_api" "main" {
  name          = "${var.p_name}GatewayMain"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "dev"
  auto_deploy = true
}

#***************************************************************************************************

resource "aws_apigatewayv2_integration" "main" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.aws_lambda_function_invoke_arn
}

resource "aws_apigatewayv2_route" "main" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /hello"

  target = "integrations/${aws_apigatewayv2_integration.main.id}"
}


#***************************************************************************************************

resource "aws_apigatewayv2_integration" "availability_integration" {
  api_id          = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  integration_uri = var.lambda_function_court_availability_invoke_arn
}

# Define the /availability resource for reservation
resource "aws_apigatewayv2_route" "availability_route" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /availability"

  target = "integrations/${aws_apigatewayv2_integration.availability_integration.id}"
}


#***************************************************************************************************

resource "aws_apigatewayv2_integration" "reservation_integration" {
  api_id          = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  integration_uri = var.lambda_function_court_reservation_invoke_arn
  integration_method = "POST"
}


# Define the /reserve resource for reservation
resource "aws_apigatewayv2_route" "reservation_route" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /reserve"

  target = "integrations/${aws_apigatewayv2_integration.reservation_integration.id}"
}

#***************************************************************************************************