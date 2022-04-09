resource "aws_api_gateway_method" "get" {
  http_method   = "GET"
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

resource "aws_api_gateway_deployment" "default" {
  rest_api_id = var.api_id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.get.id,
      aws_api_gateway_integration.get.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "default" {
  deployment_id = aws_api_gateway_deployment.default.id
  rest_api_id   = var.api_id
  stage_name    = "prod"
}