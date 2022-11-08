resource "aws_iam_user" "cloud-watcher" {
  name = "cloud-watcher"

  tags = {
    Name = "Terraform AWS GitHub Observability"
    Url  = "https://github.com/pl-strflt/tf-aws-gh-observability"
  }
}

data "aws_iam_policy" "cloud-watcher" {
  name = "CloudWatchReadOnlyAccess"
}

resource "aws_iam_user_policy_attachment" "cloud-watcher" {
  user       = aws_iam_user.cloud-watcher.name
  policy_arn = data.aws_iam_policy.cloud-watcher.arn
}
