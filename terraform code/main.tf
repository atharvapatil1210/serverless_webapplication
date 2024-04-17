# Define provider (AWS)
provider "aws" {
  region = "us-east-1"
}

# DynamoDB table for storing data
resource "aws_dynamodb_table" "items" {
  name           = "ItemsTable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }
}

# Lambda function to handle backend logic
resource "aws_lambda_function" "web_function" {
  filename      = "hunger.zip"
  function_name = "WebFunction"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
}

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_exec_role" {
  name = "LambdaExecRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# API Gateway for creating RESTful APIs
resource "aws_api_gateway_rest_api" "web_api" {
  name        = "WebAPI"
  description = "Serverless Web API"
}

# API Gateway resource
resource "aws_api_gateway_resource" "web_resource" {
  rest_api_id = aws_api_gateway_rest_api.web_api.id
  parent_id   = aws_api_gateway_rest_api.web_api.root_resource_id
  path_part   = "items"
}

# API Gateway method (POST)
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.web_api.id
  resource_id   = aws_api_gateway_resource.web_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway integration (Lambda proxy)
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.web_api.id
  resource_id             = aws_api_gateway_resource.web_resource.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.web_function.invoke_arn
}

# Deploy API Gateway
resource "aws_api_gateway_deployment" "web_api_deployment" {
  depends_on = [aws_api_gateway_integration.lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.web_api.id
  stage_name = "dev"
}

# S3 bucket for storing static assets
resource "aws_s3_bucket" "static_assets" {
  bucket_prefix = "static-assets-"
  acl           = "public-read"
}
# SES for sending emails
resource "aws_ses_email_identity" "default" {
  email = "atharvabodade@gmail.com"
}
