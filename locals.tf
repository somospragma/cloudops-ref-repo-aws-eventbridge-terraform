locals {
  # Generar nombres de recursos siguiendo la convención de nomenclatura estándar
  event_bus_name = "${var.client}-${var.project}-${var.environment}-event-bus"
  
  event_rule_names = {
    for k, v in var.event_rules : k => "${var.client}-${var.project}-${var.environment}-rule-${k}"
  }

  schedule_rule_names = {
    for k, v in var.event_rules : k => "${var.client}-${var.project}-${var.environment}-sch_rules-${k}"
  }

  dlq_name = "${var.client}-${var.project}-${var.environment}-event-bus-dlq"
}