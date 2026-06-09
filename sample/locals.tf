##############################################################################
# sample/locals.tf
# PC-IAC-009: Inyección de valores dinámicos desde data sources
# PC-IAC-021: Centraliza la configuración compleja
# PC-IAC-026: Transforma var.* antes de pasarlo al módulo
##############################################################################
locals {
  # Las reglas se pasan directamente — los ARNs de Lambda vienen del tfvars
  # En un proyecto real, los ARNs vendrían de data sources o módulos IAM/Lambda
  event_rules_transformed     = var.event_rules
  scheduled_rules_transformed = var.scheduled_rules
  sns_rules_transformed       = var.sns_rules
}
