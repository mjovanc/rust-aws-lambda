provider "aws" {
  region = var.region
}

data archive_file lambda {
  type        = "zip"
  source_file = "index.js"
  output_path = "../bootstrap.zip"
}


resource aws_iam_role iam {
  name = "iam_for_lambda_tf"

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

resource aws_iam_policy this {
  name        = format("%s-trigger-transcoder", var.full_name)
  description = "Allow to access base resources and trigger transcoder"
  policy      = jsonencode({
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "SomeVeryDefaultAndOpenActions",
                "Effect": "Allow",
                "Action": [
                    "logs:CreateLogGroup",
                    "ec2:DescribeNetworkInterfaces",
                    "ec2:CreateNetworkInterface",
                    "ec2:DeleteNetworkInterface",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                "Resource": [
                    "*"
                ]
            }
        ]
    }
  })
}

module lambda {
  function_name  = "RustLambda"
  filename       = data.archive_file.lambda.output_path
  description    = "description should be here"
  handler        = "index.handler"
  runtime        = "provided.al2"
  memory_size    = "128"
  concurrency    = "5"
  lambda_timeout = "20"
  log_retention  = "1"
  role_arn       = aws_iam_role.iam.arn

  vpc_config = {
    subnet_ids         = ["sb-q53asdfasdfasdf", "sf-3asdfasdfasdf6"]
    security_group_ids = ["sg-3asdfadsfasdfas"]
  }

  environment = {
    Environment = "test"
  }

  tags = {
    Environment = "test"
  }
  source = ""
}
