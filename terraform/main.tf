provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

#Generating the zip files
data "archive_file" "workspace_start_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/workspace_start.py"
  output_path = "${path.module}/output/workspace_start.zip"
}

data "archive_file" "workspace_stop_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/workspace_stop.py"
  output_path = "${path.module}/output/workspace_stop.zip"
}

resource "aws_lambda_function" "workspace_start" {
  filename         = "${path.module}/output/workspace_start.zip"
  function_name    = "workspace_start"
  role             = "${aws_iam_role.iam_role_for_workspace_start_stop.arn}"
  handler          = "workspace_start.lambda_handler"
  source_code_hash = "${data.archive_file.workspace_start_zip.output_base64sha256}"
  runtime          = "python2.7"
  memory_size      = "512"
  timeout          = "150"
}

resource "aws_lambda_function" "workspace_stop" {
  filename         = "${path.module}/output/workspace_stop.zip"
  function_name    = "workspace_stop"
  role             = "${aws_iam_role.iam_role_for_workspace_start_stop.arn}"
  handler          = "workspace_stop.lambda_handler"
  source_code_hash = "${data.archive_file.workspace_stop_zip.output_base64sha256}"
  runtime          = "python2.7"
  memory_size      = "512"
  timeout          = "150"
}

resource "aws_lambda_permission" "allow_cloudwatch_workspace_start" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.workspace_start.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.workspace_start_cloudwatch_rule.arn}"

  depends_on = ["aws_lambda_function.workspace_start"]
}

resource "aws_lambda_permission" "allow_cloudwatch_workspace_stop" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.workspace_stop.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.workspace_stop_cloudwatch_rule.arn}"

  depends_on = ["aws_lambda_function.workspace_stop"]
}

resource "aws_cloudwatch_event_rule" "workspace_start_cloudwatch_rule" {
  name = "workspace_start_lambda_trigger"

  #to be run between 1-4am every 3 months starting from Feb on the first sunday of the month

  schedule_expression = "${var.workspace_start_cron}"
}

resource "aws_cloudwatch_event_target" "workspace_start_lambda" {
  rule      = "${aws_cloudwatch_event_rule.workspace_start_cloudwatch_rule.name}"
  target_id = "lambda_target"
  arn       = "${aws_lambda_function.workspace_start.arn}"
}

resource "aws_cloudwatch_event_rule" "workspace_stop_cloudwatch_rule" {
  name = "workspace_stop_lambda_trigger"

  #to be run between 1-4am every 3 months starting from Feb on the first sunday of the month

  schedule_expression = "${var.workspace_stop_cron}"
}

resource "aws_cloudwatch_event_target" "workspace_stop_lambda" {
  rule      = "${aws_cloudwatch_event_rule.workspace_stop_cloudwatch_rule.name}"
  target_id = "lambda_target"
  arn       = "${aws_lambda_function.workspace_stop.arn}"
}

resource "aws_cloudwatch_log_group" "workspace_start_group" {

  name = "/aws/lambda/workspace_start"
}
resource "aws_cloudwatch_log_group" "workspace_stop_group" {

  name = "/aws/lambda/workspace_stop"
}