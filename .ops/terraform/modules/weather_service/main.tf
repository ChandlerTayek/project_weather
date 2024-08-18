#***************************************************************************************************
# Lambda
#***************************************************************************************************
resource "aws_lambda_function" "main" {
  function_name = "weather_lambda_function"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.main.repository_url}:latest"

  role          = var.lambda_iam_role_arn
  timeout = 3
  environment {
    variables = {
      WEATHER_API_KEY = "a2bb86c755d04a29a7a43426241808"  # Set this to your actual API key
    }
  }
}

resource "aws_lambda_permission" "main" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.aws_apigatewayv2_api_execution_arn}/*/*/*"
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${aws_lambda_function.main.function_name}"
  retention_in_days = 14  # Optional: Set log retention period (e.g., 14 days)
}
#***************************************************************************************************
# ECR
#***************************************************************************************************

resource "aws_ecr_repository" "main" {
  name                 = "${var.p_name}_weather_ping"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
}

# Push Docker Image to ECR
resource "null_resource" "main" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --profile ${var.aws_cli_profile} --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
      docker build -f ../../../../.ops/terraform/modules/weather_service/Dockerfile -t weather_ping ../../../../.ops/terraform/modules/weather_service/
      docker tag weather_ping:latest ${aws_ecr_repository.main.repository_url}:latest
      docker push ${aws_ecr_repository.main.repository_url}:latest
      aws lambda update-function-code --profile ${var.aws_cli_profile} --region ${var.aws_region} \
      --function-name ${aws_lambda_function.main.function_name} \
      --image-uri ${aws_ecr_repository.main.repository_url}:latest
    EOT
  }

    triggers = {
    python_file_hash = filesha256("../../../../.ops/terraform/modules/weather_service/weather_ping.py")
  }

  depends_on = [
    aws_ecr_repository.main,
    ]
}

#***************************************************************************************************
# API Gateway
#***************************************************************************************************

resource "aws_apigatewayv2_integration" "main" {
  api_id           = var.aws_apigatewayv2_api_main_id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.main.invoke_arn
}

resource "aws_apigatewayv2_route" "main" {
  api_id    = var.aws_apigatewayv2_api_main_id
  route_key = "GET /weather_ping"

  target = "integrations/${aws_apigatewayv2_integration.main.id}"
}

