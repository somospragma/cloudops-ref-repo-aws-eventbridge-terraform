output "event_bus_name" {
  description = "Name of the EventBridge bus"
  value       = var.create_custom_bus ? aws_cloudwatch_event_bus.this[0].name : "default"
}

output "event_bus_arn" {
  description = "ARN of the EventBridge bus"
  value       = var.create_custom_bus ? aws_cloudwatch_event_bus.this[0].arn : null
}

output "event_rules" {
  description = "Map of EventBridge event-based rules created"
  value = {
    for k, v in aws_cloudwatch_event_rule.this : k => {
      name = v.name
      arn  = v.arn
    }
  }
}

output "scheduled_rules" {
  description = "Map of EventBridge scheduled rules created"
  value = {
    for k, v in aws_cloudwatch_event_rule.scheduled : k => {
      name = v.name
      arn  = v.arn
    }
  }
}

output "dlq_url" {
  description = "URL of the Dead Letter Queue"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].url : null
}

output "dlq_arn" {
  description = "ARN of the Dead Letter Queue"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].arn : null
}

output "sns_rules" {
  description = "Map of EventBridge SNS-target rules created"
  value = {
    for k, v in aws_cloudwatch_event_rule.sns : k => {
      name = v.name
      arn  = v.arn
    }
  }
}
