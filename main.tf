# EventBridge Custom Bus
resource "aws_cloudwatch_event_bus" "this" {
  provider = aws.project
  count = var.create_custom_bus ? 1 : 0
  name  = local.event_bus_name

  tags = {
      Name = local.event_bus_name
    }
}

# EventBridge Rules (Event-based)
resource "aws_cloudwatch_event_rule" "this" {
  provider = aws.project
  for_each = var.event_rules

  name           = local.event_rule_names[each.key]
  description    = each.value.description
  event_bus_name = var.create_custom_bus ? aws_cloudwatch_event_bus.this[0].name : "default"
  event_pattern  = jsonencode(each.value.event_pattern)
  state          = each.value.enabled ? "ENABLED" : "DISABLED"

  tags = merge(
    {
      Name = local.event_rule_names[each.key]
    },
    each.value.additional_tags
  )
}

# EventBridge Rules (Scheduled)
resource "aws_cloudwatch_event_rule" "scheduled" {
  provider = aws.project
  for_each = var.scheduled_rules

  name                = local.schedule_rule_names[each.key]
  description         = each.value.description
  event_bus_name      = var.create_custom_bus ? aws_cloudwatch_event_bus.this[0].name : "default"
  schedule_expression = each.value.schedule_expression
  state               = each.value.enabled ? "ENABLED" : "DISABLED"

   tags = merge(
    {
      Name = local.schedule_rule_names[each.key]
    },
    each.value.additional_tags
  )
}

# EventBridge Targets (Lambda Functions for Event-based rules)
resource "aws_cloudwatch_event_target" "lambda" {
  provider = aws.project
  for_each = var.event_rules

  rule           = aws_cloudwatch_event_rule.this[each.key].name
  event_bus_name = var.create_custom_bus ? aws_cloudwatch_event_bus.this[0].name : "default"
  target_id      = "${each.key}-lambda-target"
  arn            = each.value.lambda_function_arn

  depends_on = [aws_lambda_permission.allow_eventbridge]
}

# EventBridge Targets (Lambda Functions for Scheduled rules)
resource "aws_cloudwatch_event_target" "lambda_scheduled" {
  provider = aws.project
  for_each = var.scheduled_rules

  rule           = aws_cloudwatch_event_rule.scheduled[each.key].name
  event_bus_name = var.create_custom_bus ? aws_cloudwatch_event_bus.this[0].name : "default"
  target_id      = "${each.key}-lambda-scheduled-target"
  arn            = each.value.lambda_function_arn
  input          = each.value.input

  dynamic "input_transformer" {
    for_each = each.value.input_transformer != null ? [each.value.input_transformer] : []
    content {
      input_paths    = input_transformer.value.input_paths
      input_template = input_transformer.value.input_template
    }
  }

  depends_on = [aws_lambda_permission.allow_eventbridge_scheduled]
}

# Lambda Permissions for EventBridge (Event-based rules)
resource "aws_lambda_permission" "allow_eventbridge" {
  provider = aws.project
  for_each = var.event_rules

  statement_id  = "AllowExecutionFromEventBridge-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this[each.key].arn
}

# Lambda Permissions for EventBridge (Scheduled rules)
resource "aws_lambda_permission" "allow_eventbridge_scheduled" {
  provider = aws.project
  for_each = var.scheduled_rules

  statement_id  = "AllowExecutionFromEventBridge-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled[each.key].arn
}

# Dead Letter Queue (Optional)
resource "aws_sqs_queue" "dlq" {
  provider = aws.project
  count = var.create_dlq ? 1 : 0

  name                      = local.dlq_name
  message_retention_seconds = var.dlq_message_retention_seconds

  tags = {
      Name = local.dlq_name
    }
}

# EventBridge Targets with DLQ (Event-based rules)
resource "aws_cloudwatch_event_target" "lambda_with_dlq" {
  provider = aws.project
  for_each = var.create_dlq ? var.event_rules : {}

  rule           = aws_cloudwatch_event_rule.this[each.key].name
  event_bus_name = var.create_custom_bus ? aws_cloudwatch_event_bus.this[0].name : "default"
  target_id      = "${each.key}-lambda-target-dlq"
  arn            = each.value.lambda_function_arn

  dead_letter_config {
    arn = aws_sqs_queue.dlq[0].arn
  }

  retry_policy {
    maximum_event_age_in_seconds = var.maximum_event_age_in_seconds
    maximum_retry_attempts       = var.maximum_retry_attempts
  }

  depends_on = [aws_lambda_permission.allow_eventbridge]
}

# EventBridge Targets with DLQ (Scheduled rules)
resource "aws_cloudwatch_event_target" "lambda_scheduled_with_dlq" {
  provider = aws.project
  for_each = var.create_dlq ? var.scheduled_rules : {}

  rule           = aws_cloudwatch_event_rule.scheduled[each.key].name
  event_bus_name = var.create_custom_bus ? aws_cloudwatch_event_bus.this[0].name : "default"
  target_id      = "${each.key}-lambda-scheduled-target-dlq"
  arn            = each.value.lambda_function_arn
  input          = each.value.input

  dynamic "input_transformer" {
    for_each = each.value.input_transformer != null ? [each.value.input_transformer] : []
    content {
      input_paths    = input_transformer.value.input_paths
      input_template = input_transformer.value.input_template
    }
  }

  dead_letter_config {
    arn = aws_sqs_queue.dlq[0].arn
  }

  retry_policy {
    maximum_event_age_in_seconds = var.maximum_event_age_in_seconds
    maximum_retry_attempts       = var.maximum_retry_attempts
  }

  depends_on = [aws_lambda_permission.allow_eventbridge_scheduled]
}

# ============================================================================
# SNS Target Rules
# EventBridge rules that route events to an SNS Topic instead of Lambda.
# Useful for fan-out: email subscriptions, cross-account SQS consumers, etc.
# ============================================================================

# EventBridge Rules (SNS target)
resource "aws_cloudwatch_event_rule" "sns" {
  provider = aws.project
  for_each = var.sns_rules

  name           = "${var.client}-${var.project}-${var.environment}-rule-${each.key}"
  description    = each.value.description
  event_bus_name = var.create_custom_bus ? aws_cloudwatch_event_bus.this[0].name : "default"
  event_pattern  = jsonencode(each.value.event_pattern)
  state          = each.value.enabled ? "ENABLED" : "DISABLED"

  tags = merge(
    { Name = "${var.client}-${var.project}-${var.environment}-rule-${each.key}" },
    each.value.additional_tags
  )
}

# EventBridge Targets → SNS Topic
resource "aws_cloudwatch_event_target" "sns" {
  provider = aws.project
  for_each = var.sns_rules

  rule           = aws_cloudwatch_event_rule.sns[each.key].name
  event_bus_name = var.create_custom_bus ? aws_cloudwatch_event_bus.this[0].name : "default"
  target_id      = "${each.key}-sns-target"
  arn            = each.value.sns_topic_arn
}
