# Changelog

Todas las versiones notables de este módulo se documentan en este archivo.
El formato sigue [Keep a Changelog](https://keepachangelog.com/) y el módulo
usa [Semantic Versioning](https://semver.org/).

## [v1.3.0]

### Added
- **`archive_config`**: archive del bus custom para replay
  (`aws_cloudwatch_event_archive`). Retención, patrón de eventos y descripción
  configurables. Se cifra con la misma CMK del bus cuando `kms_key_arn` está
  definido. Requiere `create_custom_bus = true`.
- **`schema_registry`**: schema registry de EventBridge para los contratos de
  evento (`aws_schemas_registry`).
- Outputs `archive_arn`, `archive_name`, `schema_registry_arn` y
  `schema_registry_name` (`null` cuando no se crean).
- `environment` acepta además `staging` y `poc`.

### Changed
- Versión mínima del provider AWS: `>= 6.2.0`, la primera que soporta
  `kms_key_identifier` en `aws_cloudwatch_event_archive`.

### Compatibilidad
- Retrocompatible a nivel de recursos: sin `archive_config` ni
  `schema_registry` (default `null`), el módulo genera los mismos recursos que
  `v1.2.0`.
- Quien use un provider AWS anterior a `6.2.0` debe actualizarlo o mantenerse
  en `v1.2.0`.

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
