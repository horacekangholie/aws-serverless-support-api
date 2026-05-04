output "project_name" {
  value = var.project_name
}

output "environment" {
  value = var.environment
}

output "aws_region" {
  value = var.aws_region
}

output "tickets_table_name" {
  value = aws_dynamodb_table.tickets.name
}

output "create_ticket_lambda_name" {
  value = aws_lambda_function.create_ticket.function_name
}

output "create_ticket_lambda_role_name" {
  value = aws_iam_role.create_ticket_lambda_role.name
}

output "create_ticket_lambda_policy_name" {
  value = aws_iam_role_policy.create_ticket_lambda_policy.name
}

output "api_endpoint" {
  value = aws_apigatewayv2_stage.dev.invoke_url
}

output "create_ticket_url" {
  value = "${aws_apigatewayv2_stage.dev.invoke_url}/tickets"
}

output "get_ticket_lambda_name" {
  value = aws_lambda_function.get_ticket.function_name
}

output "get_ticket_url_pattern" {
  value = "${aws_apigatewayv2_stage.dev.invoke_url}/tickets/{ticket_id}"
}

output "update_ticket_lambda_name" {
  value = aws_lambda_function.update_ticket.function_name
}

output "update_ticket_url_pattern" {
  value = "${aws_apigatewayv2_stage.dev.invoke_url}/tickets/{ticket_id}"
}

output "delete_ticket_lambda_name" {
  value = aws_lambda_function.delete_ticket.function_name
}

output "delete_ticket_url_pattern" {
  value = "${aws_apigatewayv2_stage.dev.invoke_url}/tickets/{ticket_id}"
}

output "list_tickets_lambda_name" {
  value = aws_lambda_function.list_tickets.function_name
}

output "list_tickets_url" {
  value = "${aws_apigatewayv2_stage.dev.invoke_url}/tickets"
}
