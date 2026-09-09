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

variable "event_rules" {
  description = "Map of EventBridge event-based rules configuration"
  type = map(object({
    description          = string
    event_pattern        = any
    lambda_function_arn  = string
    lambda_function_name = string
    enabled              = optional(bool, true)
    input                = optional(string)
    input_path           = optional(string)
    input_transformer = optional(object({
      input_paths    = optional(map(string))
      input_template = string
    }))
    additional_tags = optional(map(string), {})
  }))
  default = {}
}

variable "scheduled_rules" {
  description = "Map of scheduled EventBridge rules configuration"
  type = map(object({
    description          = string
    schedule_expression  = string
    lambda_function_arn  = string
    lambda_function_name = string
    enabled              = optional(bool, true)
    input                = optional(string)
    input_path           = optional(string)
    input_transformer = optional(object({
      input_paths    = optional(map(string))
      input_template = string
    }))
    additional_tags = optional(map(string), {})
  }))
  default = {}
}

variable "create_dlq" {
  description = "Whether to create a Dead Letter Queue for failed events"
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
