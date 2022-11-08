resource "aws_ssm_parameter" "github_app_id" {
  name   = "/events_observer/github_app_id"
  type   = "SecureString"
  value  = var.github_app_id
  tags   = local.tags
}

resource "aws_ssm_parameter" "github_app_key_base64" {
  name   = "/events_observer/github_app_key_base64"
  type   = "SecureString"
  value  = var.github_app_key_base64
  tags   = local.tags
}

resource "aws_ssm_parameter" "github_app_webhook_secret" {
  name   = "/events_observer/github_app_webhook_secret"
  type   = "SecureString"
  value  = var.github_app_webhook_secret
  tags   = local.tags
}

resource "aws_ssm_parameter" "rds_address" {
  name   = "/events_observer/rds_address"
  type   = "SecureString"
  value  = aws_db_instance.rds.address
  tags   = local.tags
}

resource "aws_ssm_parameter" "rds_port" {
  name   = "/events_observer/rds_port"
  type   = "SecureString"
  value  = aws_db_instance.rds.port
  tags   = local.tags
}

resource "aws_ssm_parameter" "rds_username" {
  name   = "/events_observer/rds_username"
  type   = "SecureString"
  value  = aws_db_instance.rds.username
  tags   = local.tags
}

resource "aws_ssm_parameter" "rds_password" {
  name   = "/events_observer/rds_password"
  type   = "SecureString"
  value  = aws_db_instance.rds.password
  tags   = local.tags
}
