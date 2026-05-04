resource "aws_apigatewayv2_api" "support_api" {
  name          = "${local.name_prefix}-http-api"
  protocol_type = "HTTP"

  tags = local.common_tags
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.support_api.id
  name        = var.environment
  auto_deploy = true

  tags = local.common_tags
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

resource "aws_lambda_permission" "allow_api_gateway_create_ticket" {
  statement_id  = "AllowExecutionFromAPIGatewayCreateTicket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_ticket.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.support_api.execution_arn}/*/*"
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

  source_arn = "${aws_apigatewayv2_api.support_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "update_ticket_lambda" {
  api_id                 = aws_apigatewayv2_api.support_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.update_ticket.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "update_ticket_route" {
  api_id    = aws_apigatewayv2_api.support_api.id
  route_key = "PATCH /tickets/{ticket_id}"
  target    = "integrations/${aws_apigatewayv2_integration.update_ticket_lambda.id}"
}

resource "aws_lambda_permission" "allow_api_gateway_update_ticket" {
  statement_id  = "AllowExecutionFromAPIGatewayUpdateTicket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_ticket.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.support_api.execution_arn}/*/*"
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

resource "aws_apigatewayv2_integration" "list_tickets_lambda" {
  api_id                 = aws_apigatewayv2_api.support_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.list_tickets.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "list_tickets_route" {
  api_id    = aws_apigatewayv2_api.support_api.id
  route_key = "GET /tickets"
  target    = "integrations/${aws_apigatewayv2_integration.list_tickets_lambda.id}"
}

resource "aws_lambda_permission" "allow_api_gateway_list_tickets" {
  statement_id  = "AllowExecutionFromAPIGatewayListTickets"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_tickets.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.support_api.execution_arn}/*/*"
}
