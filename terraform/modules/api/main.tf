data "aws_lambda_function" "default" {
  function_name = var.app_name
}

data "aws_api_gateway_rest_api" "default" {
  name = "article-gateway"
}

data "aws_api_gateway_resource" "default" {
  rest_api_id = data.aws_api_gateway_rest_api.default.id
  path        = "/article"
}

resource "aws_api_gateway_method" "default" {
  http_method   = "POST"
  authorization = "NONE"
  resource_id   = data.aws_api_gateway_resource.default.id
  rest_api_id   = data.aws_api_gateway_rest_api.default.id
}

resource "aws_api_gateway_integration" "default" {
  resource_id             = data.aws_api_gateway_resource.default.id
  rest_api_id             = data.aws_api_gateway_rest_api.default.id
  http_method             = aws_api_gateway_method.default.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${data.aws_lambda_function.default.arn}:$${stageVariables.alias}/invocations"
  depends_on              = [aws_api_gateway_method.default]
}

resource "aws_api_gateway_deployment" "default" {
  rest_api_id = data.aws_api_gateway_rest_api.default.id
  stage_name = "dev"

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      data.aws_api_gateway_resource.default.id,
      aws_api_gateway_method.default.id,
      aws_api_gateway_integration.default.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "default" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.app_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${data.aws_api_gateway_rest_api.default.execution_arn}/*/*"
}

resource "aws_api_gateway_method_response" "default" {
  rest_api_id = data.aws_api_gateway_rest_api.default.id
  resource_id = data.aws_api_gateway_resource.default.id
  http_method = aws_api_gateway_method.default.http_method
  status_code = 200
}