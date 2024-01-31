provider "aws" {
  region = "eu-north-1"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_lambda_function" "rust_lambda_function" {
  function_name    = "rustLambdaFunction"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda-api::handler"
  runtime          = "provided.al2"
  filename         = "../bootstrap.zip"
  source_code_hash = filebase64("../bootstrap.zip")
}

resource "aws_apigatewayv2_api" "api" {
  name          = "rust_lambda_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "integration" {
  api_id             = aws_apigatewayv2_api.api.id
  integration_uri    = aws_lambda_function.rust_lambda_function.invoke_arn
  integration_method = ["POST", "GET", "OPTION", "HEAD"]
  integration_type   = "AWS_PROXY"
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "ANY /{proxy+}"

  target = aws_apigatewayv2_integration.integration.id
}

resource "aws_lambda_permission" "apigateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rust_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
}
