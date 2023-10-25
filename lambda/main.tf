resource "random_pet" "lambda_bucket_name" {
  prefix = "vova-webflux"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id
}

data "archive_file" "delay_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../trigger"
  output_path = "${path.module}/../trigger.zip"
}

resource "aws_s3_object" "delay_lambda" {
  depends_on = [aws_s3_bucket.lambda_bucket]
  bucket     = aws_s3_bucket.lambda_bucket.id
  key        = "trigger.zip"
  source     = data.archive_file.delay_lambda.output_path
  etag       = filemd5(data.archive_file.delay_lambda.output_path)
}

resource "aws_lambda_function" "delay_lambda" {
  function_name = "RequestDelay"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.delay_lambda.key

  runtime = "nodejs18.x"
  handler = "main.handler"

  source_code_hash = data.archive_file.delay_lambda.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id
  name        = "api"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "delay_lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.delay_lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "delay" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "GET /delay"
  target    = "integrations/${aws_apigatewayv2_integration.delay_lambda.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delay_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

