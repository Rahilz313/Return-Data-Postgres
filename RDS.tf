provider "aws" {
  region = "us-east-1" # Change to your desired region
}

resource "aws_db_instance" "example" {
  identifier             = "example-postgres"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.1"
  instance_class         = "db.t3.micro"
  username               = "rahil"
  password               = "Rahil1234"
  publicly_accessible    = true
  multi_az               = false
}

# Creating a Role 
resource "aws_iam_role" "lambda_role" {
  name               = "databaselambdarole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = "sts:AssumeRole",
        Effect   = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attaching policies to the created role
resource "aws_iam_policy_attachment" "rds_full_access" {
  name       = "rds-full-access"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
  roles      = [aws_iam_role.lambda_role.name]
}

resource "aws_iam_policy_attachment" "vpc_full_access" {
  name       = "vpc-full-access"
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
  roles      = [aws_iam_role.lambda_role.name]
}

resource "aws_iam_policy_attachment" "Lambda_basic_execution" {
  name       = "lambda-basic-execution"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles      = [aws_iam_role.lambda_role.name]
}

resource "aws_iam_policy_attachment" "Lambda_vpc_exection_role" {
  name       = "lambda-vpc-execution"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  roles      = [aws_iam_role.lambda_role.name]
}

resource "aws_lambda_function" "my_lambda_function" {
  function_name = "Database-Connection"
  role          = aws_iam_role.lambda_role.arn
  handler       = "state_handler.lambda_handler"  # Corrected typo
  runtime       = "provided.al2"
  image_uri     = "934036565719.dkr.ecr.us-east-1.amazonaws.com/image:latest"
  package_type  = "Image"
}
