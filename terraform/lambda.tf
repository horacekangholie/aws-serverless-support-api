data "archive_file" "create_ticket_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/app.py"
  output_path = "${path.module}/create_ticket_lambda.zip"
}

data "archive_file" "get_ticket_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/app.py"
  output_path = "${path.module}/get_ticket_lambda.zip"
}

data "archive_file" "update_ticket_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/app.py"
  output_path = "${path.module}/update_ticket_lambda.zip"
}

data "archive_file" "delete_ticket_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/app.py"
  output_path = "${path.module}/delete_ticket_lambda.zip"
}

data "archive_file" "list_tickets_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/app.py"
  output_path = "${path.module}/list_tickets_lambda.zip"
}

resource "aws_lambda_function" "create_ticket" {
  function_name = "${local.name_prefix}-create-ticket"
  role          = aws_iam_role.create_ticket_lambda_role.arn
  handler       = "app.create_ticket_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.create_ticket_lambda_zip.output_path
  source_code_hash = data.archive_file.create_ticket_lambda_zip.output_base64sha256

  environment {
    variables = {
      TICKETS_TABLE_NAME = aws_dynamodb_table.tickets.name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.create_ticket_lambda_logs
  ]

  tags = local.common_tags
}

resource "aws_lambda_function" "get_ticket" {
  function_name = "${local.name_prefix}-get-ticket"
  role          = aws_iam_role.get_ticket_lambda_role.arn
  handler       = "app.get_ticket_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.get_ticket_lambda_zip.output_path
  source_code_hash = data.archive_file.get_ticket_lambda_zip.output_base64sha256

  environment {
    variables = {
      TICKETS_TABLE_NAME = aws_dynamodb_table.tickets.name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.get_ticket_lambda_logs
  ]

  tags = local.common_tags
}

resource "aws_lambda_function" "update_ticket" {
  function_name = "${local.name_prefix}-update-ticket"
  role          = aws_iam_role.update_ticket_lambda_role.arn
  handler       = "app.update_ticket_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.update_ticket_lambda_zip.output_path
  source_code_hash = data.archive_file.update_ticket_lambda_zip.output_base64sha256

  environment {
    variables = {
      TICKETS_TABLE_NAME = aws_dynamodb_table.tickets.name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.update_ticket_lambda_logs
  ]

  tags = local.common_tags
}

resource "aws_lambda_function" "delete_ticket" {
  function_name = "${local.name_prefix}-delete-ticket"
  role          = aws_iam_role.delete_ticket_lambda_role.arn
  handler       = "app.delete_ticket_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.delete_ticket_lambda_zip.output_path
  source_code_hash = data.archive_file.delete_ticket_lambda_zip.output_base64sha256

  environment {
    variables = {
      TICKETS_TABLE_NAME = aws_dynamodb_table.tickets.name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.delete_ticket_lambda_logs
  ]

  tags = local.common_tags
}

resource "aws_lambda_function" "list_tickets" {
  function_name = "${local.name_prefix}-list-tickets"
  role          = aws_iam_role.list_tickets_lambda_role.arn
  handler       = "app.list_tickets_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.list_tickets_lambda_zip.output_path
  source_code_hash = data.archive_file.list_tickets_lambda_zip.output_base64sha256

  environment {
    variables = {
      TICKETS_TABLE_NAME = aws_dynamodb_table.tickets.name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.list_tickets_lambda_logs
  ]

  tags = local.common_tags
}
