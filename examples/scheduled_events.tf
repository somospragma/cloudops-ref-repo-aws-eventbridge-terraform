# Ejemplo de uso del módulo EventBridge con eventos programados

# Funciones Lambda de ejemplo para eventos programados
resource "aws_lambda_function" "daily_report" {
  filename         = "daily_report.zip"
  function_name    = "daily-report-generator"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 300
  source_code_hash = filebase64sha256("daily_report.zip")
}

resource "aws_lambda_function" "cleanup_task" {
  filename         = "cleanup.zip"
  function_name    = "cleanup-old-files"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 600
  source_code_hash = filebase64sha256("cleanup.zip")
}

resource "aws_lambda_function" "health_check" {
  filename         = "health_check.zip"
  function_name    = "system-health-check"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 60
  source_code_hash = filebase64sha256("health_check.zip")
}

resource "aws_lambda_function" "backup_task" {
  filename         = "backup.zip"
  function_name    = "weekly-backup"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 900
  source_code_hash = filebase64sha256("backup.zip")
}

# Rol IAM para las funciones Lambda
resource "aws_iam_role" "lambda_role" {
  name = "eventbridge-scheduled-lambda-role"

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

# Uso del módulo EventBridge con eventos programados
module "eventbridge_scheduled" {
  source = "../"

  event_bus_name    = "scheduled-events-bus"
  create_custom_bus = true

  # Solo eventos programados
  scheduled_rules = {
    "daily-report" = {
      description          = "Generate daily report every day at 9 AM UTC"
      schedule_expression  = "cron(0 9 * * ? *)"
      lambda_function_arn  = aws_lambda_function.daily_report.arn
      lambda_function_name = aws_lambda_function.daily_report.function_name
      input = jsonencode({
        report_type = "daily"
        format      = "pdf"
        recipients  = ["admin@company.com"]
      })
    }
    
    "cleanup-hourly" = {
      description          = "Cleanup old files every hour"
      schedule_expression  = "rate(1 hour)"
      lambda_function_arn  = aws_lambda_function.cleanup_task.arn
      lambda_function_name = aws_lambda_function.cleanup_task.function_name
      input = jsonencode({
        cleanup_type = "temp_files"
        max_age_hours = 24
      })
    }
    
    "health-check" = {
      description          = "System health check every 5 minutes"
      schedule_expression  = "rate(5 minutes)"
      lambda_function_arn  = aws_lambda_function.health_check.arn
      lambda_function_name = aws_lambda_function.health_check.function_name
    }
    
    "weekly-backup" = {
      description          = "Weekly backup every Sunday at 2 AM UTC"
      schedule_expression  = "cron(0 2 ? * SUN *)"
      lambda_function_arn  = aws_lambda_function.backup_task.arn
      lambda_function_name = aws_lambda_function.backup_task.function_name
      input_transformer = {
        input_paths = {
          timestamp = "$.time"
        }
        input_template = jsonencode({
          backup_type = "weekly"
          timestamp   = "<timestamp>"
          retention_days = 30
        })
      }
    }
    
    "monthly-billing" = {
      description          = "Monthly billing report on first day of month"
      schedule_expression  = "cron(0 0 1 * ? *)"
      lambda_function_arn  = aws_lambda_function.daily_report.arn
      lambda_function_name = aws_lambda_function.daily_report.function_name
      enabled              = true
      input = jsonencode({
        report_type = "monthly_billing"
        format      = "excel"
      })
    }
  }

  create_dlq = true
  
  tags = {
    Environment = "production"
    Project     = "scheduled-tasks"
    Owner       = "ops-team"
  }
}

# Outputs
output "scheduled_rules" {
  description = "Scheduled rules created"
  value       = module.eventbridge_scheduled.scheduled_rules
}

output "event_bus_name" {
  description = "EventBridge bus name"
  value       = module.eventbridge_scheduled.event_bus_name
}

output "dlq_url" {
  description = "Dead Letter Queue URL"
  value       = module.eventbridge_scheduled.dlq_url
}
