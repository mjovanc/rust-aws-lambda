provider "aws" {
  region = "eu-north-1"
}

data "aws_iam_role" "existing_lambda_role" {
  name = "lambda_exec_role"
}

resource "aws_iam_role" "lambda_execution_role" {
  count = data.aws_iam_role.existing_lambda_role ? 0 : 1

  name = "lambda_exec_role"

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
  count = data.aws_lambda_function.existing_lambda_function ? 0 : 1

  function_name    = "rustAWSLambdaFunc"
  role             = aws_iam_role.lambda_execution_role[0].arn
  handler          = "lambda-api::handler"
  runtime          = "provided.al2"
  filename         = "../bootstrap.zip"
  source_code_hash = filebase64("../bootstrap.zip")
}

data "aws_lambda_function" "existing_lambda_function" {
  function_name = "rustAWSLambdaFunc"
}

resource "aws_apigatewayv2_api" "api" {
  name          = "rust_lambda_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "prod"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "integration" {
  api_id             = aws_apigatewayv2_api.api.id
  integration_uri    = aws_lambda_function.rust_lambda_function[0].invoke_arn
  integration_method = "POST"
  integration_type   = "AWS_PROXY"
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "ANY /{proxy+}"
  target   = aws_apigatewayv2_integration.integration[0].id
}

resource "aws_lambda_permission" "apigateway_permission" {
  count          = data.aws_lambda_function.existing_lambda_function ? 1 : 0
  statement_id   = "AllowExecutionFromAPIGateway"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.rust_lambda_function[0].function_name
  principal      = "apigateway.amazonaws.com"
}
