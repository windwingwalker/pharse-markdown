resource "aws_api_gateway_method" "get" {
  http_method   = "POST"
  authorization = "NONE"
  resource_id   = var.api_resource_id
  rest_api_id   = var.api_id
}

resource "aws_api_gateway_integration" "get" {
  rest_api_id             = var.api_id
  resource_id             = var.api_resource_id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_invoke_arn
  depends_on              = [aws_api_gateway_method.get]
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.app_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_execution_arn}/*/*"
}

resource "aws_api_gateway_method_response" "get_200" {
  rest_api_id = var.api_id
  resource_id = var.api_resource_id
  http_method = aws_api_gateway_method.get.http_method
  status_code = 200
}