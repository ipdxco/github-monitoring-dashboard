# terraform init
# export AWS_ACCESS_KEY_ID=
# export AWS_SECRET_ACCESS_KEY=
# export AWS_REGION=
# export TF_VAR_name=
# export TF_VAR_rds_rw_password=
# export TF_VAR_rds_ro_password=
# export TF_VAR_github_app_key_base64=
# export TF_VAR_github_app_id=
# export TF_VAR_github_app_webhook_secret=
# export TF_VAR_organization_allow_list=
# export TF_VAR_log_type=
# export TF_VAR_log_level=
# export TF_VAR_logging_retention_in_days=
# terraform apply

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.9.0"
    }
    local = {
      source = "hashicorp/local"
    }
    random = {
      source = "hashicorp/random"
    }
  }

  required_version = "~> 1.3.7"
}

locals {
  tags = {
    Name = "GitHub Monitoring Dashboard"
    Url  = "https://github.com/ipdxco/github-monitoring-dashboard"
  }
}

provider "aws" {}

variable "name" {}

variable "rds_rw_password" {}

variable "rds_ro_password" {}

variable "github_app_key_base64" {}

variable "github_app_id" {}

variable "github_app_webhook_secret" {}

variable "organization_allow_list" {
  description = "List of org names allowed to use the github app"
  type        = list(string)
  default     = []
}

variable "log_type" {
  description = "Logging format for lambda logging. Valid values are 'json', 'pretty', 'hidden'. "
  type        = string
  default     = "pretty"
  validation {
    condition = anytrue([
      var.log_type == "json",
      var.log_type == "pretty",
      var.log_type == "hidden",
    ])
    error_message = "`log_type` value not valid. Valid values are 'json', 'pretty', 'hidden'."
  }
}

variable "log_level" {
  description = "Logging level for lambda logging. Valid values are  'silly', 'trace', 'debug', 'info', 'warn', 'error', 'fatal'."
  type        = string
  default     = "info"
  validation {
    condition = anytrue([
      var.log_level == "silly",
      var.log_level == "trace",
      var.log_level == "debug",
      var.log_level == "info",
      var.log_level == "warn",
      var.log_level == "error",
      var.log_level == "fatal",
    ])
    error_message = "`log_level` value not valid. Valid values are 'silly', 'trace', 'debug', 'info', 'warn', 'error', 'fatal'."
  }
}

variable "logging_retention_in_days" {
  description = "Specifies the number of days you want to retain log events for the lambda log group. Possible values are: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
  type        = number
  default     = 7
}

data "aws_region" "default" {}
