provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

#Generating the zip files
data "archive_file" "ec2_start_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/ec2_start.py"
  output_path = "${path.module}/output/ec2_start.zip"
}

data "archive_file" "ec2_stop_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/ec2_stop.py"
  output_path = "${path.module}/output/ec2_stop.zip"
}

resource "aws_lambda_function" "ec2_start" {
  filename         = "${path.module}/output/ec2_start.zip"
  function_name    = "ec2_start"
  role             = "${aws_iam_role.iam_role_for_ec2_start_stop.arn}"
  handler          = "ec2_start.lambda_handler"
  source_code_hash = "${data.archive_file.ec2_start_zip.output_base64sha256}"
  runtime          = "python2.7"
  memory_size      = "512"
  timeout          = "150"
}

resource "aws_lambda_function" "ec2_stop" {
  filename         = "${path.module}/output/ec2_stop.zip"
  function_name    = "ec2_stop"
  role             = "${aws_iam_role.iam_role_for_ec2_start_stop.arn}"
  handler          = "ec2_stop.lambda_handler"
  source_code_hash = "${data.archive_file.ec2_stop_zip.output_base64sha256}"
  runtime          = "python2.7"
  memory_size      = "512"
  timeout          = "150"
}

resource "aws_lambda_permission" "allow_cloudwatch_ec2_start" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ec2_start.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ec2_start_cloudwatch_rule.arn}"

  depends_on = ["aws_lambda_function.ec2_start"]
}

resource "aws_lambda_permission" "allow_cloudwatch_ec2_stop" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ec2_stop.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.ec2_stop_cloudwatch_rule.arn}"

  depends_on = ["aws_lambda_function.ec2_stop"]
}

resource "aws_cloudwatch_event_rule" "ec2_start_cloudwatch_rule" {
  name = "ec2_start_lambda_trigger"

  #to be run between 1-4am every 3 months starting from Feb on the first sunday of the month

  schedule_expression = "${var.ec2_start_cron}"
}

resource "aws_cloudwatch_event_target" "ec2_start_lambda" {
  rule      = "${aws_cloudwatch_event_rule.ec2_start_cloudwatch_rule.name}"
  target_id = "lambda_target"
  arn       = "${aws_lambda_function.ec2_start.arn}"
}

resource "aws_cloudwatch_event_rule" "ec2_stop_cloudwatch_rule" {
  name = "ec2_stop_lambda_trigger"

  #to be run between 1-4am every 3 months starting from Feb on the first sunday of the month

  schedule_expression = "${var.ec2_stop_cron}"
}

resource "aws_cloudwatch_event_target" "ec2_stop_lambda" {
  rule      = "${aws_cloudwatch_event_rule.ec2_stop_cloudwatch_rule.name}"
  target_id = "lambda_target"
  arn       = "${aws_lambda_function.ec2_stop.arn}"
}
