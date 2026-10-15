locals {
  # Generar nombres de recursos siguiendo la convención de nomenclatura estándar
  event_bus_name = "${var.client}-${var.project}-${var.environment}-event-bus"

  event_rule_names = {
    for k, v in var.event_rules : k => "${var.client}-${var.project}-${var.environment}-rule-${k}"
  }

  schedule_rule_names = {
    for k, v in var.scheduled_rules : k => "${var.client}-${var.project}-${var.environment}-sch-rule-${k}"
  }

  dlq_name = "${var.client}-${var.project}-${var.environment}-event-bus-dlq"

  # --- Extensión target SQS -------------------------------------------------
  # Filtra las reglas (event-based y scheduled) que declaran target Lambda vs
  # target SQS, para crear los recursos condicionalmente sin romper el
  # comportamiento original del módulo (que asumía siempre Lambda).
  #
  # Filtra por target_type (string estático) y NO por lambda_function_arn/
  # sqs_target_arn != "" — esos ARNs suelen venir de otro módulo en la misma
  # composición (ej. module.sqs.queue_arns[...]) y son "known after apply"
  # en el primer plan; un for_each cuyas keys dependen de un filtro sobre un
  # valor así rompe con "Invalid for_each argument". target_type sí se
  # conoce en tiempo de plan porque el usuario lo declara como literal.
  event_rules_with_lambda = {
    for k, v in var.event_rules : k => v if v.target_type == "lambda"
  }
  event_rules_with_sqs = {
    for k, v in var.event_rules : k => v if v.target_type == "sqs"
  }

  scheduled_rules_with_lambda = {
    for k, v in var.scheduled_rules : k => v if v.target_type == "lambda"
  }
  scheduled_rules_with_sqs = {
    for k, v in var.scheduled_rules : k => v if v.target_type == "sqs"
  }
}
