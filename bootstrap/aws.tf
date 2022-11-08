# terraform init
# export AWS_ACCESS_KEY_ID=
# export AWS_SECRET_ACCESS_KEY=
# terraform apply

terraform {
  required_providers {
    aws = {
      version = "4.5.0"
    }
  }

  required_version = "~> 1.1.4"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "this" {
  bucket = "tf-aws-gh-observability"

  tags = {
    Name = "Terraform AWS GitHub Observability"
    Url  = "https://github.com/pl-strflt/tf-aws-gh-observability"
  }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

resource "aws_dynamodb_table" "this" {
  name         = "tf-aws-gh-observability"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform AWS GitHub Observability"
    Url  = "https://github.com/pl-strflt/tf-aws-gh-observability"
  }
}

resource "aws_iam_user" "this" {
  name = "tf-aws-gh-observability"

  tags = {
    Name = "Terraform AWS GitHub Observability"
    Url  = "https://github.com/pl-strflt/tf-aws-gh-observability"
  }
}

# The list of policies might be too broad for this project
data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "iam:*",
      "s3:*",
      "lambda:*",
      "ssm:*",
      "apigateway:*",
      "dynamodb:*",
      "logs:*",
      "rds:*",
      "ec2:*",
    ]
    resources = ["*"]
    effect = "Allow"
  }
}

resource "aws_iam_user_policy" "this" {
  name = "tf-aws-gh-observability"
  user = "${aws_iam_user.this.name}"

  policy = "${data.aws_iam_policy_document.this.json}"
}
