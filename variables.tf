variable "environment" {
  description = "Entorno de despliegue (dev, qa, pdn, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "pdn", "prod"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn, prod."
  }
}

variable "client" {
  description = "Nombre del cliente"
  type        = string

  validation {
    condition     = length(var.client) > 0
    error_message = "El nombre del cliente no puede estar vacío."
  }
}

variable "project" {
  description = "Nombre del proyecto"
  type        = string

  validation {
    condition     = length(var.project) > 0
    error_message = "El nombre del proyecto no puede estar vacío."
  }
}

variable "create_custom_bus" {
  description = "Whether to create a custom EventBridge bus or use the default bus"
  type        = bool
  default     = false
}

# Cifrado en reposo del bus custom con CMK propia. Solo tiene efecto cuando
# create_custom_bus = true. Vacío ("") = cifrado por defecto de EventBridge
# (clave gestionada por AWS), consistente con el comportamiento original del
# módulo antes de esta extensión.
variable "kms_key_arn" {
  description = "ARN de la CMK que cifra el bus custom. Vacío = cifrado por defecto de EventBridge (no aplica si create_custom_bus = false)."
  type        = string
  default     = ""

  validation {
    condition     = var.kms_key_arn == "" || startswith(var.kms_key_arn, "arn:aws:kms:")
    error_message = "kms_key_arn debe ser el ARN de una CMK (arn:aws:kms:...) o una cadena vacía."
  }
}

variable "event_rules" {
  description = "Map of EventBridge event-based rules configuration"
  type = map(object({
    description   = string
    event_pattern = any

    # target_type es un string ESTÁTICO ("lambda" | "sqs") declarado por el
    # usuario — a diferencia de filtrar por lambda_function_arn/sqs_target_arn
    # != "", este campo se conoce en tiempo de plan aunque el ARN del target
    # (típicamente el output de otro módulo, ej. module.sqs.queue_arns[...])
    # solo se conozca tras el apply. Filtrar el for_each interno del módulo
    # por un valor dinámico (el ARN) rompe "terraform plan" con
    # "Invalid for_each argument: ... will be known only after apply" en
    # cualquier composición real donde el target se cree en el mismo plan.
    target_type = string

    # Target Lambda (comportamiento original del módulo). Requerido cuando
    # target_type = "lambda".
    lambda_function_arn  = optional(string, "")
    lambda_function_name = optional(string, "")

    # Target SQS (extensión). Requerido cuando target_type = "sqs".
    sqs_target_arn = optional(string, "")

    # dead_letter_config y retry_policy del target SQS. Solo tienen efecto
    # cuando target_type = "sqs" — el target Lambda sigue usando
    # exclusivamente var.create_dlq (comportamiento original).
    sqs_dead_letter_arn           = optional(string, "")
    sqs_maximum_event_age_seconds = optional(number, 3600)
    sqs_maximum_retry_attempts    = optional(number, 5)
    sqs_message_group_id          = optional(string, "") # solo para colas FIFO

    enabled    = optional(bool, true)
    input      = optional(string)
    input_path = optional(string)
    input_transformer = optional(object({
      input_paths    = optional(map(string))
      input_template = string
    }))
    additional_tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.event_rules : contains(["lambda", "sqs"], v.target_type)
    ])
    error_message = "target_type debe ser 'lambda' o 'sqs'."
  }

  validation {
    condition = alltrue([
      for k, v in var.event_rules :
      (v.target_type == "lambda" && v.lambda_function_arn != "") || (v.target_type == "sqs" && v.sqs_target_arn != "")
    ])
    error_message = "Cada event_rule debe declarar lambda_function_arn (si target_type = \"lambda\") o sqs_target_arn (si target_type = \"sqs\")."
  }
}

variable "scheduled_rules" {
  description = "Map of scheduled EventBridge rules configuration"
  type = map(object({
    description         = string
    schedule_expression = string

    # Ver la nota de target_type en event_rules — mismo motivo (evitar
    # for_each dinámico sobre valores "known after apply").
    target_type = string

    lambda_function_arn  = optional(string, "")
    lambda_function_name = optional(string, "")

    sqs_target_arn = optional(string, "")

    sqs_dead_letter_arn           = optional(string, "")
    sqs_maximum_event_age_seconds = optional(number, 3600)
    sqs_maximum_retry_attempts    = optional(number, 5)
    sqs_message_group_id          = optional(string, "")

    enabled    = optional(bool, true)
    input      = optional(string)
    input_path = optional(string)
    input_transformer = optional(object({
      input_paths    = optional(map(string))
      input_template = string
    }))
    additional_tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.scheduled_rules : contains(["lambda", "sqs"], v.target_type)
    ])
    error_message = "target_type debe ser 'lambda' o 'sqs'."
  }

  validation {
    condition = alltrue([
      for k, v in var.scheduled_rules :
      (v.target_type == "lambda" && v.lambda_function_arn != "") || (v.target_type == "sqs" && v.sqs_target_arn != "")
    ])
    error_message = "Cada scheduled_rule debe declarar lambda_function_arn (si target_type = \"lambda\") o sqs_target_arn (si target_type = \"sqs\")."
  }
}

variable "create_dlq" {
  description = "Whether to create a Dead Letter Queue for failed events (targets Lambda). Los targets SQS usan sus propios campos sqs_dead_letter_arn por regla."
  type        = bool
  default     = false
}

variable "dlq_message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message in the DLQ"
  type        = number
  default     = 1209600 # 14 days
}

variable "maximum_event_age_in_seconds" {
  description = "The maximum age of a request that Lambda sends to a function for processing"
  type        = number
  default     = 21600 # 6 hours
}

variable "maximum_retry_attempts" {
  description = "The maximum number of times to retry when the function returns an error"
  type        = number
  default     = 2
}

variable "tags" {
  description = "Tags comunes para aplicar a todos los recursos del módulo"
  type        = map(string)
  default     = {}
}
