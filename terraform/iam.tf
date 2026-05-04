resource "aws_iam_role" "create_ticket_lambda_role" {
  name = "${local.name_prefix}-create-ticket-lambda-role"

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
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.create_ticket_lambda_logs.arn}:*"
      }
    ]
  })
}

resource "aws_iam_role" "get_ticket_lambda_role" {
  name = "${local.name_prefix}-get-ticket-lambda-role"

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