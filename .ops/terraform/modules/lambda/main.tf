resource "aws_lambda_function" "api-gateway" {
  function_name = "${var.p_name}ApiGateway"
  package_type  = "Image"
  image_uri     = "${var.api-gateway-image-uri}:latest"

  role = aws_iam_role.main.arn
  timeout = 15

  # Ensure Lambda creation waits for Docker image push
  depends_on = [var.docker_image_push_obj]
}

resource "aws_iam_role" "main" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "lambda-dynamodb-policy"
  description = "Policy to allow Lambda to access DynamoDB"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ],
        Resource = var.aws_dynamodb_table_court_availability_reservations_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "dynamodb_attachment" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

resource "aws_cloudwatch_log_group" "api-gateway" {
  name              = "/aws/lambda/${aws_lambda_function.api-gateway.function_name}"
  retention_in_days = 14  # Optional: Set log retention period (e.g., 14 days)
}

resource "aws_lambda_permission" "main" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api-gateway.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.aws_apigatewayv2_api_execution_arn}/*/*/*"
}

#***************************************************************************************************

# Define Lambda function for Court Availability using Docker image
resource "aws_lambda_function" "court_availability_lambda" {
  function_name = "${var.p_name}CourtAvailability"
  role          = aws_iam_role.main.arn
  package_type  = "Image"
  image_uri     = "${var.availability-image-uri}:latest"
  timeout       = 30

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.aws_dynamodb_table_court_reservations_name
    }
  }

  # Ensure Lambda creation waits for Docker image push
  depends_on = [var.docker_image_push_obj]
}

resource "aws_cloudwatch_log_group" "court_availability" {
  name              = "/aws/lambda/${aws_lambda_function.court_availability_lambda.function_name}"
  retention_in_days = 14  # Optional: Set log retention period (e.g., 14 days)
}

resource "aws_lambda_permission" "court_availability" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.court_availability_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.aws_apigatewayv2_api_execution_arn}/*/*/*"
}
#***************************************************************************************************

# Define Lambda function for Court Reservation using Docker image
resource "aws_lambda_function" "court_reservation_lambda" {
  function_name = "${var.p_name}CourtReservation"
  role          = aws_iam_role.main.arn
  package_type  = "Image"
  image_uri     = "${var.reservation-image-uri}:latest"
  timeout       = 30

  # Pass the DynamoDB table name as an environment variable
  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.aws_dynamodb_table_court_reservations_name
    }
  }

  # Ensure Lambda creation waits for Docker image push
  depends_on = [var.docker_image_push_obj]
}

resource "aws_cloudwatch_log_group" "court_reservation" {
  name              = "/aws/lambda/${aws_lambda_function.court_reservation_lambda.function_name}"
  retention_in_days = 14  # Optional: Set log retention period (e.g., 14 days)
}

resource "aws_lambda_permission" "court_reservation" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.court_reservation_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.aws_apigatewayv2_api_execution_arn}/*/*/*"
}