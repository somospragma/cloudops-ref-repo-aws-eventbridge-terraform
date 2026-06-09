variable "environment" {
  description = "Entorno de despliegue (dev, qa, pdn)"
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

# variable "event_bus_name" {
#   description = "Name of the EventBridge custom bus"
#   type        = string
#   default     = "custom-event-bus"
# }

variable "create_custom_bus" {
  description = "Whether to create a custom EventBridge bus or use the default bus"
  type        = bool
  default     = false
}

variable "event_rules" {
  description = "Map of EventBridge rules configuration"
  type = map(object({
    description          = string
    event_pattern        = optional(any)
    schedule_expression  = optional(string)
    lambda_function_arn  = string
    lambda_function_name = string
    enabled              = optional(bool, true)
    additional_tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.event_rules : (v.event_pattern != null) != (v.schedule_expression != null)
    ])
    error_message = "Each rule must have either event_pattern OR schedule_expression, but not both."
  }
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

variable "scheduled_rules" {
  description = "Map of scheduled EventBridge rules configuration"
  type = map(object({
    description          = string
    schedule_expression  = string
    lambda_function_arn  = string
    lambda_function_name = string
    enabled              = optional(bool, true)
    input                = optional(string)
    input_transformer    = optional(object({
      input_paths    = optional(map(string))
      input_template = string
    }))
    additional_tags = optional(map(string), {})
  }))
  default = {}
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

variable "sns_rules" {
  description = "Map of EventBridge rules with SNS topic as target. Used to fan-out domain events to SNS for further distribution (email, SQS cross-account, etc.)"
  type = map(object({
    description     = string
    event_pattern   = any
    sns_topic_arn   = string
    enabled         = optional(bool, true)
    additional_tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.sns_rules : length(v.sns_topic_arn) > 0
    ])
    error_message = "sns_topic_arn must not be empty for each sns_rule."
  }
}
