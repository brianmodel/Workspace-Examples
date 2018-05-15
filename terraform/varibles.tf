variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_profile" {}

variable "ec2_start_cron" {
  default = "cron(0 8 ? * MON-FRI *)"
}

variable "ec2_stop_cron" {
  default = "cron(0 20 ? * MON-FRI *)"
}
