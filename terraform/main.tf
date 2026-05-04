locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_dynamodb_table" "tickets" {
  name         = "${local.name_prefix}-tickets"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ticket_id"
  attribute {
    name = "ticket_id"
    type = "S" # String type
  }
  tags = local.common_tags
}

data "archive_file" "create_ticket_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/create_ticket/app.py"
  output_path = "${path.module}/create_ticket_lambda.zip"
}

resource "aws_iam_role" "create_ticket_lambda_role" {
  name = "${local.name_prefix}-create-ticket-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = local.common_tags
}

resource "aws_iam_role_policy" "create_ticket_lambda_policy" {
  name = "${local.name_prefix}-create-ticket-lambda-policy"
  role = aws_iam_role.create_ticket_lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem"
        ]
        Resource = aws_dynamodb_table.tickets.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "create_ticket" {
  function_name = "${local.name_prefix}-create-ticket"
  role          = aws_iam_role.create_ticket_lambda_role.arn
  handler       = "app.handler"
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

resource "aws_apigatewayv2_api" "support_api" {
  name          = "${local.name_prefix}-http-api"
  protocol_type = "HTTP"
  tags          = local.common_tags
}

resource "aws_apigatewayv2_integration" "create_ticket_lambda" {
  api_id                 = aws_apigatewayv2_api.support_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.create_ticket.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "create_ticket_route" {
  api_id    = aws_apigatewayv2_api.support_api.id
  route_key = "POST /tickets"
  target    = "integrations/${aws_apigatewayv2_integration.create_ticket_lambda.id}"
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.support_api.id
  name        = var.environment
  auto_deploy = true
  tags        = local.common_tags
}

resource "aws_lambda_permission" "allow_api_gateway_create_ticket" {
  statement_id  = "AllowExecutionFromAPIGatewayCreateTicket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_ticket.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.support_api.execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "create_ticket_lambda_logs" {
  name              = "/aws/lambda/${local.name_prefix}-create-ticket"
  retention_in_days = 14
  tags              = local.common_tags
}

data "archive_file" "get_ticket_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/get_ticket/app.py"
  output_path = "${path.module}/get_ticket_lambda.zip"
}

resource "aws_cloudwatch_log_group" "get_ticket_lambda_logs" {
  name              = "/aws/lambda/${local.name_prefix}-get-ticket"
  retention_in_days = 14
  tags              = local.common_tags
}

resource "aws_iam_role" "get_ticket_lambda_role" {
  name = "${local.name_prefix}-get-ticket-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "get_ticket_lambda_policy" {
  name = "${local.name_prefix}-get-ticket-lambda-policy"
  role = aws_iam_role.get_ticket_lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem"
        ]
        Resource = aws_dynamodb_table.tickets.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.get_ticket_lambda_logs.arn}:*"
      }
    ]
  })
}

resource "aws_lambda_function" "get_ticket" {
  function_name = "${local.name_prefix}-get-ticket"
  role          = aws_iam_role.get_ticket_lambda_role.arn
  handler       = "app.handler"
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

resource "aws_apigatewayv2_integration" "get_ticket_lambda" {
  api_id                 = aws_apigatewayv2_api.support_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.get_ticket.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "get_ticket_route" {
  api_id    = aws_apigatewayv2_api.support_api.id
  route_key = "GET /tickets/{ticket_id}"
  target    = "integrations/${aws_apigatewayv2_integration.get_ticket_lambda.id}"
}

resource "aws_lambda_permission" "allow_api_gateway_get_ticket" {
  statement_id  = "AllowExecutionFromAPIGatewayGetTicket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_ticket.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.support_api.execution_arn}/*/*"
}

data "archive_file" "update_ticket_status_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/update_ticket_status/app.py"
  output_path = "${path.module}/update_ticket_status_lambda.zip"
}

resource "aws_cloudwatch_log_group" "update_ticket_status_lambda_logs" {
  name              = "/aws/lambda/${local.name_prefix}-update-ticket-status"
  retention_in_days = 14

  tags = local.common_tags
}

resource "aws_iam_role" "update_ticket_status_lambda_role" {
  name = "${local.name_prefix}-update-ticket-status-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "update_ticket_status_lambda_policy" {
  name = "${local.name_prefix}-update-ticket-status-lambda-policy"
  role = aws_iam_role.update_ticket_status_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:UpdateItem"
        ]
        Resource = aws_dynamodb_table.tickets.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.update_ticket_status_lambda_logs.arn}:*"
      }
    ]
  })
}

resource "aws_lambda_function" "update_ticket_status" {
  function_name = "${local.name_prefix}-update-ticket-status"
  role          = aws_iam_role.update_ticket_status_lambda_role.arn
  handler       = "app.handler"
  runtime       = "python3.12"

  filename         = data.archive_file.update_ticket_status_lambda_zip.output_path
  source_code_hash = data.archive_file.update_ticket_status_lambda_zip.output_base64sha256

  environment {
    variables = {
      TICKETS_TABLE_NAME = aws_dynamodb_table.tickets.name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.update_ticket_status_lambda_logs
  ]

  tags = local.common_tags
}

resource "aws_apigatewayv2_integration" "update_ticket_status_lambda" {
  api_id                 = aws_apigatewayv2_api.support_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.update_ticket_status.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "update_ticket_route" {
  api_id    = aws_apigatewayv2_api.support_api.id
  route_key = "PATCH /tickets/{ticket_id}"
  target    = "integrations/${aws_apigatewayv2_integration.update_ticket_status_lambda.id}"
}

resource "aws_lambda_permission" "allow_api_gateway_update_ticket_status" {
  statement_id  = "AllowExecutionFromAPIGatewayUpdateTicketStatus"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_ticket_status.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.support_api.execution_arn}/*/*"
}

data "archive_file" "delete_ticket_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/delete_ticket/app.py"
  output_path = "${path.module}/delete_ticket_lambda.zip"
}

resource "aws_cloudwatch_log_group" "delete_ticket_lambda_logs" {
  name              = "/aws/lambda/${local.name_prefix}-delete-ticket"
  retention_in_days = 14

  tags = local.common_tags
}

resource "aws_iam_role" "delete_ticket_lambda_role" {
  name = "${local.name_prefix}-delete-ticket-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "delete_ticket_lambda_policy" {
  name = "${local.name_prefix}-delete-ticket-lambda-policy"
  role = aws_iam_role.delete_ticket_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.tickets.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.delete_ticket_lambda_logs.arn}:*"
      }
    ]
  })
}

resource "aws_lambda_function" "delete_ticket" {
  function_name = "${local.name_prefix}-delete-ticket"
  role          = aws_iam_role.delete_ticket_lambda_role.arn
  handler       = "app.handler"
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

resource "aws_apigatewayv2_integration" "delete_ticket_lambda" {
  api_id                 = aws_apigatewayv2_api.support_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.delete_ticket.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "delete_ticket_route" {
  api_id    = aws_apigatewayv2_api.support_api.id
  route_key = "DELETE /tickets/{ticket_id}"
  target    = "integrations/${aws_apigatewayv2_integration.delete_ticket_lambda.id}"
}

resource "aws_lambda_permission" "allow_api_gateway_delete_ticket" {
  statement_id  = "AllowExecutionFromAPIGatewayDeleteTicket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_ticket.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.support_api.execution_arn}/*/*"
}





