resource "aws_cloudwatch_log_group" "create_ticket_lambda_logs" {
  name              = "/aws/lambda/${local.name_prefix}-create-ticket"
  retention_in_days = 14

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "get_ticket_lambda_logs" {
  name              = "/aws/lambda/${local.name_prefix}-get-ticket"
  retention_in_days = 14

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "update_ticket_lambda_logs" {
  name              = "/aws/lambda/${local.name_prefix}-update-ticket"
  retention_in_days = 14

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "delete_ticket_lambda_logs" {
  name              = "/aws/lambda/${local.name_prefix}-delete-ticket"
  retention_in_days = 14

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "list_tickets_lambda_logs" {
  name              = "/aws/lambda/${local.name_prefix}-list-tickets"
  retention_in_days = 14

  tags = local.common_tags
}
