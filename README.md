# Rust + AWS Lambda <!-- omit in toc -->

![build](https://img.shields.io/github/actions/workflow/status/mjovanc/rust-aws-lambda/ci.yml?branch=master)
[![rust-aws-lambda: rustc 1.75+](https://img.shields.io/badge/compiler-rustc_1.75+-lightgray.svg)](https://blog.rust-lang.org/2023/11/16/Rust-1.74.0.html)

This project is intended to demonstrate how to build a simple HTTP function in Rust and provision it to AWS with AWS Lambda using Terraform.

## Getting Started

First we need to configure AWS, so you have the access to provision necessary infrastructure on AWS.

### Create the GitHub Identity Provider

Navigate to IAM > Identity providers and create a new provider. Select OpenID Connect and add the following:

**Provider URL:** `https://token.actions.githubusercontent.com` \
**Audience:** `sts.amazonaws.com`

### Create the AWS role

Navigate to IAM > Roles and create a new role. Select **Web Identity** and choose the just created identity provider. Add the permissions you want to role to have, in this example we will use the AWS managed permission **AdministratorAccess** (please do not use it in production).

After the role has been created we are going to add the GitHub repo to the Trust relationships. After editing the trusted entities JSON should look something like this:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::12345678:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:mjovanc/rust-aws-lambda:*"
                }
            }
        }
    ]
}
```

### Add `permissions` to the job in `ci.yml`

```yaml
permissions:
  id-token: write # This is required for requesting the JWT
  contents: read  # This is required for actions/checkout
```

### Update the AWS configure action in `ci.yml`

We need to update the `role-to-assume` to match your IAM account number and the role name.

```yaml
- name: Configure AWS Credentials
  uses: aws-actions/configure-aws-credentials@v2
  with:
    role-to-assume: arn:aws:iam::12345678:role/YourRoleNameHere
    aws-region: eu-west-1
```

Now you should be good to go and can run run the workflow.

## License

The GPLv3 License.
