resource "aws_api_gateway_rest_api" "TeamSequoiaAPI" {
  name        = "TeamSequoiaAPI"
  description = "This is Team Sequoia' API."
}

resource "aws_api_gateway_resource" "TeamSequoiaAPIresource" {
  rest_api_id = aws_api_gateway_rest_api.TeamSequoiaAPI.id
  parent_id   = aws_api_gateway_rest_api.TeamSequoiaAPI.root_resource_id
  path_part   = var.endpoint_path
}

resource "aws_api_gateway_method" "TeamSequoiaAPI_Get_Method" {
  rest_api_id   = aws_api_gateway_rest_api.TeamSequoiaAPI.id
  resource_id   = aws_api_gateway_resource.TeamSequoiaAPIresource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "TeamSequoiaAPI_Post_Method" {
  rest_api_id   = aws_api_gateway_rest_api.TeamSequoiaAPI.id
  resource_id   = aws_api_gateway_resource.TeamSequoiaAPIresource.id
  http_method   = "POST"
  authorization = "NONE"
}

data "aws_lambda_function" "lambda" {
  function_name = aws_lambda_function.lambda.function_name
}

resource "aws_api_gateway_integration" "Get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.TeamSequoiaAPI.id
  resource_id             = aws_api_gateway_resource.TeamSequoiaAPIresource.id
  http_method             = aws_api_gateway_method.TeamSequoiaAPI_Get_Method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.lambda.arn
}

resource "aws_api_gateway_integration" "Post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.TeamSequoiaAPI.id
  resource_id             = aws_api_gateway_resource.TeamSequoiaAPIresource.id
  http_method             = aws_api_gateway_method.TeamSequoiaAPI_Post_Method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.lambda.arn
}

resource "aws_api_gateway_method" "TeamSequoia_options" {
  rest_api_id   = aws_api_gateway_rest_api.TeamSequoiaAPI.id
  resource_id   = aws_api_gateway_resource.TeamSequoiaAPIresource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "TeamSequoia_options_200" {
  rest_api_id = aws_api_gateway_rest_api.TeamSequoiaAPI.id
  resource_id = aws_api_gateway_resource.TeamSequoiaAPIresource.id
  http_method = aws_api_gateway_method.TeamSequoia_options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "TeamSequoia_options" {
  rest_api_id = aws_api_gateway_rest_api.TeamSequoiaAPI.id
  resource_id = aws_api_gateway_resource.TeamSequoiaAPIresource.id
  http_method = aws_api_gateway_method.TeamSequoia_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode" : 200
}
EOF
  }
}

resource "aws_api_gateway_integration_response" "TeamSequoia_options" {
  rest_api_id = aws_api_gateway_rest_api.TeamSequoiaAPI.id
  resource_id = aws_api_gateway_resource.TeamSequoiaAPIresource.id
  http_method = aws_api_gateway_method.TeamSequoia_options.http_method
  status_code = aws_api_gateway_method_response.TeamSequoia_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_lambda_permission" "TeamSequoiaapigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.TeamSequoiaAPI.execution_arn}/*/*${aws_api_gateway_resource.TeamSequoiaAPIresource.path}"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on    = [
    aws_api_gateway_integration.Get_integration,
    aws_api_gateway_integration.Post_integration,
    aws_api_gateway_integration.TeamSequoia_options,
  ]
  rest_api_id   = aws_api_gateway_rest_api.TeamSequoiaAPI.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.TeamSequoiaAPI.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api-stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.TeamSequoiaAPI.id
  stage_name    = "dev"
}

output "api_url" {
  value = aws_api_gateway_deployment.api_deployment.invoke_url
}
