resource "aws_iam_user" "lambda-service-user" {
  name = "lambda-service-user"
}

resource "aws_iam_access_key" "lambda-service-user" {
  user = aws_iam_user.lambda-service-user.name
}

resource aws_iam_policy this {
  name        = format("%s-trigger-transcoder", "test")
  description = "Allow to access base resources and trigger transcoder"
  policy      = jsonencode(
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
    })
}

resource "aws_iam_user_policy_attachment" "lambda-service-user-policy-attachment" {
  user       = aws_iam_user.lambda-service-user.name
  policy_arn = aws_iam_policy.this.arn
}

output "aws_access_key_id" {
  value = aws_iam_access_key.lambda-service-user.id
}

output "aws_secret_access_key" {
  value     = aws_iam_access_key.lambda-service-user.secret
  sensitive = true
}