# Changelog

Todas las versiones notables de este módulo se documentan en este archivo.
El formato sigue [Keep a Changelog](https://keepachangelog.com/) y el módulo
usa [Semantic Versioning](https://semver.org/).

## [v1.2.0]

### Added
- **Target SQS** en `event_rules` y `scheduled_rules`: una regla ahora puede
  enrutar el evento directamente a una cola SQS (`aws_cloudwatch_event_target.sqs`
  y `sqs_scheduled`), con su propia `dead_letter_config` y `retry_policy` por
  regla (`sqs_dead_letter_arn`, `sqs_maximum_event_age_seconds`,
  `sqs_maximum_retry_attempts`, `sqs_message_group_id` para FIFO).
- Nuevo campo obligatorio **`target_type`** (`"lambda"` | `"sqs"`) por regla,
  declarado como string estático para evitar `Invalid for_each argument` cuando
  el ARN del target proviene de otro módulo en la misma composición.
- **`kms_key_arn`**: cifrado del bus custom con una CMK propia. El módulo no crea
  la clave, la recibe como variable. Vacío = cifrado por defecto de EventBridge.
- Validaciones: cada regla debe declarar un `target_type` válido y el ARN del
  target correspondiente.

### Changed
- `lambda_function_arn` / `lambda_function_name` pasan de requeridos a opcionales
  (solo requeridos cuando `target_type = "lambda"`).

### Compatibilidad
- Retrocompatible a nivel de recursos: una regla con `target_type = "lambda"`
  genera exactamente los mismos recursos que `v1.1.0`. El único cambio de
  interfaz es que `target_type` ahora es obligatorio en cada regla.

## [v1.1.0]
- Soporte de input transformation.

## [v1.0.0]
- Versión inicial: bus custom/default, reglas event-based y scheduled, target
  Lambda, DLQ opcional.
