##############################################################################
# sample/main.tf — Invocación del módulo EventBridge
# PC-IAC-013: Solo invoca el módulo con local.* (nunca var.* directos para config compleja)
# PC-IAC-021: main.tf limpio, sin bloques locals{}
# PC-IAC-026: Patrón tfvars → variables.tf → locals.tf → main.tf → module
##############################################################################
module "eventbridge" {
  # A. Fuente del módulo (PC-IAC-015)
  source = "../"

  # B. Providers (PC-IAC-005)
  providers = {
    aws.project = aws.principal
  }

  # C. Variables de Gobernanza (PC-IAC-003, PC-IAC-004)
  client      = var.client
  project     = var.project
  environment = var.environment

  # E. Variables de Configuración — consume locals transformados (PC-IAC-026)
  create_custom_bus = var.create_custom_bus
  event_rules       = local.event_rules_transformed
  scheduled_rules   = local.scheduled_rules_transformed
  sns_rules         = local.sns_rules_transformed
  create_dlq        = var.create_dlq
}
