terraform {
  backend "s3" {
    # account_id = "642361402189"
    region               = "us-east-1"
    bucket               = "tf-aws-gh-observability"
    key                  = "terraform.tfstate"
    dynamodb_table       = "tf-aws-gh-observability"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
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
    Name = "Terraform AWS GitHub Observability"
    Url  = "https://github.com/pl-strflt/tf-aws-gh-observability"
  }
}

provider "aws" {}

variable "rds_username" {}

variable "rds_password" {}

variable "github_app_key_base64" {}

variable "github_app_id" {}

variable "github_app_webhook_secret" {}

variable "organization_allow_list" {
  description = "List of org names allowed to use the github app"
  type        = list(string)
  default     = ["pl-strflt", "testground", "ipfs", "libp2p"]
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
