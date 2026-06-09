##############################################################################
# sample/outputs.tf
# PC-IAC-007: Outputs granulares para validar el ejemplo
##############################################################################

output "event_bus_name" {
  description = "Nombre del EventBridge bus usado."
  value       = module.eventbridge.event_bus_name
}

output "event_rules" {
  description = "Reglas EventBridge con Lambda target creadas."
  value       = module.eventbridge.event_rules
}

output "scheduled_rules" {
  description = "Reglas EventBridge programadas creadas."
  value       = module.eventbridge.scheduled_rules
}

output "sns_rules" {
  description = "Reglas EventBridge con SNS target creadas."
  value       = module.eventbridge.sns_rules
}

output "dlq_url" {
  description = "URL de la Dead Letter Queue (si create_dlq = true)."
  value       = module.eventbridge.dlq_url
}
