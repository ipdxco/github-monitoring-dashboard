# terraform init
# export AWS_ACCESS_KEY_ID=
# export AWS_SECRET_ACCESS_KEY=
# export TF_VAR_name=
# terraform apply

terraform {
  required_providers {
    aws = {
      version = "4.5.0"
    }
  }

  required_version = "~> 1.3.7"
}

provider "aws" {
  region = "us-east-1"
}

variable "name" {
  description = "The name to use for S3 bucket, DynamoDB table and IAM users."
  type        = string
}

resource "aws_s3_bucket" "this" {
  bucket = var.name

  tags = {
    Name = "GitHub Monitoring Dashboard"
    Url  = "https://github.com/ipdxco/github-monitoring-dashboard"
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "this" {
  depends_on = [ aws_s3_bucket_ownership_controls.this ]

  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

resource "aws_dynamodb_table" "this" {
  name         = var.name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "GitHub Monitoring Dashboard"
    Url  = "https://github.com/ipdxco/github-monitoring-dashboard"
  }
}

resource "aws_iam_user" "this" {
  name = var.name

  tags = {
    Name = "GitHub Monitoring Dashboard"
    Url  = "https://github.com/ipdxco/github-monitoring-dashboard"
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
  name = var.name
  user = "${aws_iam_user.this.name}"

  policy = "${data.aws_iam_policy_document.this.json}"
}
