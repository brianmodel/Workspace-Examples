variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_profile" {
  default = "sandbox"
}

variable "workspace_start_cron" {
  default = "cron(0 8 ? * MON-FRI *)"
}

variable "workspace_stop_cron" {
  default = "cron(0 20 ? * MON-FRI *)"
}
