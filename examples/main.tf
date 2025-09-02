# Ejemplo de uso del módulo EventBridge con eventos basados en patrones y programados

# Funciones Lambda de ejemplo (deben existir previamente)
resource "aws_lambda_function" "user_signup_handler" {
  filename         = "user_signup_handler.zip"
  function_name    = "user-signup-handler"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  source_code_hash = filebase64sha256("user_signup_handler.zip")
}

resource "aws_lambda_function" "order_processor" {
  filename         = "order_processor.zip"
  function_name    = "order-processor"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  source_code_hash = filebase64sha256("order_processor.zip")
}

resource "aws_lambda_function" "daily_report" {
  filename         = "daily_report.zip"
  function_name    = "daily-report"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 300
  source_code_hash = filebase64sha256("daily_report.zip")
}

resource "aws_lambda_function" "cleanup_task" {
  filename         = "cleanup.zip"
  function_name    = "cleanup-task"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 600
  source_code_hash = filebase64sha256("cleanup.zip")
}

# Rol IAM para las funciones Lambda
resource "aws_iam_role" "lambda_role" {
  name = "eventbridge-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Uso del módulo EventBridge con eventos basados en patrones y programados
module "eventbridge" {
  source = "../"

  event_bus_name    = "my-application-bus"
  create_custom_bus = true

  # Reglas basadas en eventos
  event_rules = {
    "user-signup" = {
      description          = "Rule for user signup events"
      lambda_function_arn  = aws_lambda_function.user_signup_handler.arn
      lambda_function_name = aws_lambda_function.user_signup_handler.function_name
      event_pattern = {
        source      = ["myapp.users"]
        detail-type = ["User Signup"]
        detail = {
          status = ["completed"]
        }
      }
    }
    
    "order-processing" = {
      description          = "Rule for order processing events"
      lambda_function_arn  = aws_lambda_function.order_processor.arn
      lambda_function_name = aws_lambda_function.order_processor.function_name
      event_pattern = {
        source      = ["myapp.orders"]
        detail-type = ["Order Created", "Order Updated"]
      }
    }
  }

  # Reglas programadas
  scheduled_rules = {
    "daily-report" = {
      description          = "Generate daily report at 9 AM UTC"
      schedule_expression  = "cron(0 9 * * ? *)"
      lambda_function_arn  = aws_lambda_function.daily_report.arn
      lambda_function_name = aws_lambda_function.daily_report.function_name
      input = jsonencode({
        report_type = "daily"
        format      = "pdf"
      })
    }
    
    "cleanup-task" = {
      description          = "Cleanup old files every hour"
      schedule_expression  = "rate(1 hour)"
      lambda_function_arn  = aws_lambda_function.cleanup_task.arn
      lambda_function_name = aws_lambda_function.cleanup_task.function_name
    }
  }

  create_dlq = true
  
  tags = {
    Environment = "development"
    Project     = "my-app"
    Owner       = "development-team"
  }
}

# Outputs
output "event_bus_name" {
  value = module.eventbridge.event_bus_name
}

output "event_rules" {
  value = module.eventbridge.event_rules
}

output "scheduled_rules" {
  value = module.eventbridge.scheduled_rules
}

output "dlq_url" {
  value = module.eventbridge.dlq_url
}
