##############################################################################
# sample/variables.tf
# PC-IAC-002: type, description y validation obligatorios
##############################################################################

variable "client" {
  type        = string
  description = "Nombre del cliente para nomenclatura."
  validation {
    condition     = length(var.client) > 0
    error_message = "El client no puede estar vacío."
  }
}

variable "project" {
  type        = string
  description = "Nombre del proyecto para nomenclatura."
  validation {
    condition     = length(var.project) > 0
    error_message = "El project no puede estar vacío."
  }
}

variable "environment" {
  type        = string
  description = "Entorno de despliegue: dev, qa, pdn."
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "El environment debe ser dev, qa o pdn."
  }
}

variable "create_custom_bus" {
  type        = bool
  description = "Si true, crea un custom EventBridge bus. Si false, usa el default bus."
  default     = false
}

variable "create_dlq" {
  type        = bool
  description = "Si true, crea una Dead Letter Queue para eventos fallidos."
  default     = false
}

# Configuración base — sin Lambda ARNs hardcodeados (PC-IAC-026)
variable "event_rules" {
  description = "Reglas EventBridge basadas en event pattern → Lambda target."
  type = map(object({
    description          = string
    event_pattern        = any
    lambda_function_arn  = string
    lambda_function_name = string
    enabled              = optional(bool, true)
    additional_tags      = optional(map(string), {})
  }))
  default = {}
}

variable "scheduled_rules" {
  description = "Reglas EventBridge basadas en schedule → Lambda target."
  type = map(object({
    description          = string
    schedule_expression  = string
    lambda_function_arn  = string
    lambda_function_name = string
    enabled              = optional(bool, true)
    input                = optional(string)
    input_transformer = optional(object({
      input_paths    = optional(map(string))
      input_template = string
    }))
    additional_tags = optional(map(string), {})
  }))
  default = {}
}

variable "sns_rules" {
  description = "Reglas EventBridge con SNS como target para fan-out."
  type = map(object({
    description     = string
    event_pattern   = any
    sns_topic_arn   = string
    enabled         = optional(bool, true)
    additional_tags = optional(map(string), {})
  }))
  default = {}
}
