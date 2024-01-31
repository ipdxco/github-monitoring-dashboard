resource "aws_apigatewayv2_api" "webhook" {
  name          = "gateway-github-monitoring-dashboard"
  protocol_type = "HTTP"
  tags          = local.tags
}

resource "aws_apigatewayv2_route" "webhook" {
  api_id    = aws_apigatewayv2_api.webhook.id
  route_key = "POST /webhook"
  target    = "integrations/${aws_apigatewayv2_integration.webhook.id}"
}

resource "aws_apigatewayv2_stage" "webhook" {
  lifecycle {
    ignore_changes = [
      // see bug https://github.com/terraform-providers/terraform-provider-aws/issues/12893
      default_route_settings,
      // not terraform managed
      deployment_id
    ]
  }

  api_id      = aws_apigatewayv2_api.webhook.id
  name        = "$default"
  auto_deploy = true
  tags = local.tags
}

resource "aws_apigatewayv2_integration" "webhook" {
  lifecycle {
    ignore_changes = [
      // not terraform managed
      passthrough_behavior
    ]
  }

  api_id           = aws_apigatewayv2_api.webhook.id
  integration_type = "AWS_PROXY"

  connection_type    = "INTERNET"
  description        = "GitHub App webhook for receiving events."
  integration_method = "POST"
  integration_uri    = aws_lambda_function.webhook.invoke_arn

  request_parameters = {
    "overwrite:header.x-github-organization" = "$request.body.organization.login"
    "overwrite:header.x-github-repository" = "$request.body.repository.name"
  }
}

resource "aws_lambda_function" "webhook" {
  filename          = "${path.module}/lambdas/webhook/webhook.zip"
  source_code_hash  = filebase64sha256("${path.module}/lambdas/webhook/webhook.zip")
  function_name     = "webhook-github-monitoring-dashboard"
  role              = aws_iam_role.webhook_lambda.arn
  handler           = "index.githubWebhook"
  runtime           = "nodejs16.x"
  timeout           = 10
  architectures     = ["x86_64"]

  environment {
    variables = {
      LOG_LEVEL                        = var.log_level
      LOG_TYPE                         = var.log_type
      ORGANIZATION_ALLOW_LIST          = jsonencode(var.organization_allow_list)
    }
  }

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "webhook" {
  name              = "/aws/lambda/${aws_lambda_function.webhook.function_name}"
  retention_in_days = var.logging_retention_in_days
  tags              = local.tags
}

resource "aws_lambda_permission" "webhook" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.webhook.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.webhook.execution_arn}/*/*/webhook"
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "webhook_lambda" {
  name                 = "role-github-monitoring-dashboard"
  assume_role_policy   = data.aws_iam_policy_document.lambda_assume_role_policy.json
  path                 = "/github-monitoring-dashboard/"
  tags                 = local.tags
}

resource "aws_iam_role_policy" "webhook_logging" {
  name = "logging-policy-github-monitoring-dashboard"
  role = aws_iam_role.webhook_lambda.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.webhook.arn}*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "webhook_ssm" {
  name = "ssm-policy-github-monitoring-dashboard"
  role = aws_iam_role.webhook_lambda.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = [
          "${aws_ssm_parameter.github_app_id.arn}",
          "${aws_ssm_parameter.github_app_key_base64.arn}",
          "${aws_ssm_parameter.github_app_webhook_secret.arn}",
          "${aws_ssm_parameter.rds_address.arn}",
          "${aws_ssm_parameter.rds_port.arn}",
          "${aws_ssm_parameter.rds_username.arn}",
          "${aws_ssm_parameter.rds_password.arn}"
        ]
      }
    ]
  })
}
