# AWS EventBridge Terraform Module

## Descripción

Este módulo de Terraform proporciona una solución completa para la gestión de Amazon EventBridge, permitiendo la creación y configuración de buses de eventos personalizados, reglas de eventos basadas en patrones, reglas programadas (scheduled), targets de Lambda y colas de mensajes fallidos (Dead Letter Queue). El módulo está diseñado para facilitar la implementación de arquitecturas event-driven en AWS, siguiendo las mejores prácticas de seguridad y nomenclatura estándar.

## Características

- **Bus de eventos personalizado**: Creación opcional de un bus de eventos personalizado o uso del bus por defecto
- **Reglas basadas en eventos**: Configuración de reglas que responden a patrones específicos de eventos
- **Reglas programadas**: Soporte para eventos programados usando expresiones cron o rate
- **Integración con Lambda**: Configuración automática de targets y permisos para funciones Lambda
- **Dead Letter Queue**: Cola opcional para manejo de eventos fallidos con políticas de reintento
- **Transformación de entrada**: Soporte para transformar datos de entrada usando input transformers
- **Nomenclatura estándar**: Convención de nombres consistente basada en cliente, proyecto y entorno
- **Validaciones**: Validaciones de entrada para garantizar configuraciones correctas
- **Etiquetado**: Soporte completo para etiquetado de recursos

## Estructura del Módulo

```
.
├── main.tf              # Recursos principales de EventBridge
├── variables.tf         # Definición de variables de entrada
├── outputs.tf          # Valores de salida del módulo
├── locals.tf           # Variables locales y nomenclatura
├── providers.tf        # Configuración de providers y versiones
└── examples/           # Ejemplos de uso
    ├── main.tf         # Ejemplo completo con eventos y programación
    └── scheduled_events.tf  # Ejemplo específico de eventos programados
```

## Implementación y Configuración

### Requisitos Previos

- Terraform >= 1.0.0
- AWS Provider >= 4.31.0
- Funciones Lambda existentes para usar como targets
- Permisos IAM apropiados para crear recursos de EventBridge

### Configuración Básica

```hcl
module "eventbridge" {
  source = "path/to/module"

  # Configuración básica
  environment = "dev"
  client      = "mi-cliente"
  project     = "mi-proyecto"

  # Bus personalizado (opcional)
  create_custom_bus = true

  # Reglas basadas en eventos
  event_rules = {
    "user-signup" = {
      description          = "Procesar registros de usuarios"
      lambda_function_arn  = aws_lambda_function.user_handler.arn
      lambda_function_name = aws_lambda_function.user_handler.function_name
      event_pattern = {
        source      = ["myapp.users"]
        detail-type = ["User Signup"]
      }
    }
  }

  # Reglas programadas
  scheduled_rules = {
    "daily-report" = {
      description          = "Reporte diario a las 9 AM"
      schedule_expression  = "cron(0 9 * * ? *)"
      lambda_function_arn  = aws_lambda_function.report_handler.arn
      lambda_function_name = aws_lambda_function.report_handler.function_name
    }
  }

  # Dead Letter Queue
  create_dlq = true
}
```

## Tabla de Parámetros

### Variables Requeridas

| Variable | Tipo | Descripción | Validación |
|----------|------|-------------|------------|
| `environment` | `string` | Entorno de despliegue | Debe ser: dev, qa, pdn |
| `client` | `string` | Nombre del cliente | No puede estar vacío |
| `project` | `string` | Nombre del proyecto | No puede estar vacío |

### Variables Opcionales

| Variable | Tipo | Valor por Defecto | Descripción |
|----------|------|-------------------|-------------|
| `create_custom_bus` | `bool` | `false` | Crear bus personalizado o usar el por defecto |
| `event_rules` | `map(object)` | `{}` | Configuración de reglas basadas en eventos |
| `scheduled_rules` | `map(object)` | `{}` | Configuración de reglas programadas |
| `create_dlq` | `bool` | `false` | Crear Dead Letter Queue |
| `dlq_message_retention_seconds` | `number` | `1209600` | Retención de mensajes en DLQ (14 días) |
| `maximum_event_age_in_seconds` | `number` | `21600` | Edad máxima de eventos (6 horas) |
| `maximum_retry_attempts` | `number` | `2` | Intentos máximos de reintento |

### Estructura de event_rules

```hcl
event_rules = {
  "rule-name" = {
    description          = string           # Descripción de la regla
    event_pattern        = any             # Patrón de eventos (JSON)
    lambda_function_arn  = string          # ARN de la función Lambda
    lambda_function_name = string          # Nombre de la función Lambda
    enabled              = bool            # Opcional: true por defecto
    additional_tags      = map(string)     # Opcional: etiquetas adicionales
  }
}
```

### Estructura de scheduled_rules

```hcl
scheduled_rules = {
  "rule-name" = {
    description          = string           # Descripción de la regla
    schedule_expression  = string          # Expresión cron o rate
    lambda_function_arn  = string          # ARN de la función Lambda
    lambda_function_name = string          # Nombre de la función Lambda
    enabled              = bool            # Opcional: true por defecto
    input                = string          # Opcional: entrada JSON
    input_transformer    = object({        # Opcional: transformador de entrada
      input_paths    = map(string)
      input_template = string
    })
    additional_tags      = map(string)     # Opcional: etiquetas adicionales
  }
}
```

## Outputs

| Output | Descripción |
|--------|-------------|
| `event_bus_name` | Nombre del bus de eventos |
| `event_bus_arn` | ARN del bus de eventos (si es personalizado) |
| `event_rules` | Mapa de reglas basadas en eventos creadas |
| `scheduled_rules` | Mapa de reglas programadas creadas |
| `dlq_url` | URL de la Dead Letter Queue (si está habilitada) |
| `dlq_arn` | ARN de la Dead Letter Queue (si está habilitada) |

## Ejemplos de Uso

### Ejemplo 1: Configuración Básica con Eventos

```hcl
module "eventbridge_basic" {
  source = "./modules/eventbridge"

  environment = "dev"
  client      = "acme"
  project     = "ecommerce"

  event_rules = {
    "order-created" = {
      description          = "Procesar órdenes creadas"
      lambda_function_arn  = aws_lambda_function.order_processor.arn
      lambda_function_name = aws_lambda_function.order_processor.function_name
      event_pattern = {
        source      = ["ecommerce.orders"]
        detail-type = ["Order Created"]
        detail = {
          status = ["pending"]
        }
      }
    }
  }
}
```

### Ejemplo 2: Eventos Programados con Transformación

```hcl
module "eventbridge_scheduled" {
  source = "./modules/eventbridge"

  environment = "pdn"
  client      = "acme"
  project     = "reporting"

  create_custom_bus = true

  scheduled_rules = {
    "weekly-report" = {
      description         = "Reporte semanal los lunes"
      schedule_expression = "cron(0 8 ? * MON *)"
      lambda_function_arn = aws_lambda_function.report_generator.arn
      lambda_function_name = aws_lambda_function.report_generator.function_name
      input_transformer = {
        input_paths = {
          timestamp = "$.time"
        }
        input_template = jsonencode({
          report_type = "weekly"
          timestamp   = "<timestamp>"
          format      = "pdf"
        })
      }
    }
  }

  create_dlq = true
}
```

### Ejemplo 3: Configuración Completa con DLQ

```hcl
module "eventbridge_complete" {
  source = "./modules/eventbridge"

  environment = "pdn"
  client      = "acme"
  project     = "platform"

  create_custom_bus = true

  event_rules = {
    "user-events" = {
      description          = "Eventos de usuario"
      lambda_function_arn  = aws_lambda_function.user_handler.arn
      lambda_function_name = aws_lambda_function.user_handler.function_name
      event_pattern = {
        source = ["platform.users"]
        detail-type = ["User Created", "User Updated", "User Deleted"]
      }
      additional_tags = {
        Team = "backend"
        Critical = "true"
      }
    }
  }

  scheduled_rules = {
    "maintenance" = {
      description         = "Mantenimiento nocturno"
      schedule_expression = "cron(0 2 * * ? *)"
      lambda_function_arn = aws_lambda_function.maintenance.arn
      lambda_function_name = aws_lambda_function.maintenance.function_name
      input = jsonencode({
        task_type = "cleanup"
        dry_run   = false
      })
    }
  }

  create_dlq                    = true
  dlq_message_retention_seconds = 604800  # 7 días
  maximum_retry_attempts        = 3
  maximum_event_age_in_seconds  = 43200   # 12 horas
}
```

## Escenarios de Uso Comunes

### 1. Arquitectura de Microservicios
- **Comunicación asíncrona**: Desacoplar servicios mediante eventos
- **Procesamiento de órdenes**: Manejar flujos de trabajo complejos
- **Notificaciones**: Enviar alertas basadas en eventos del sistema

### 2. Automatización y Programación
- **Reportes automáticos**: Generar reportes periódicos
- **Mantenimiento programado**: Ejecutar tareas de limpieza y optimización
- **Monitoreo de salud**: Verificaciones regulares del sistema

### 3. Integración de Sistemas
- **ETL programado**: Extracción, transformación y carga de datos
- **Sincronización de datos**: Mantener consistencia entre sistemas
- **Backup automático**: Respaldos programados de datos críticos

### 4. Procesamiento de Eventos en Tiempo Real
- **Análisis de logs**: Procesar eventos de aplicaciones
- **Detección de fraude**: Análisis en tiempo real de transacciones
- **Personalización**: Responder a comportamientos de usuarios

## Seguridad y Cumplimiento

### Mejores Prácticas de Seguridad

1. **Principio de Menor Privilegio**
   - Las funciones Lambda solo reciben permisos específicos de EventBridge
   - Permisos granulares por función y regla

2. **Cifrado en Tránsito**
   - Todas las comunicaciones utilizan HTTPS/TLS
   - EventBridge cifra automáticamente los datos en tránsito

3. **Gestión de Errores**
   - Dead Letter Queue para eventos fallidos
   - Políticas de reintento configurables
   - Monitoreo de eventos no procesados

4. **Auditoría y Logging**
   - CloudTrail registra todas las operaciones de EventBridge
   - CloudWatch Logs para debugging y monitoreo
   - Métricas detalladas de rendimiento

### Configuraciones de Seguridad

```hcl
# Ejemplo de configuración segura
module "eventbridge_secure" {
  source = "./modules/eventbridge"

  environment = "pdn"
  client      = "secure-client"
  project     = "critical-app"

  # Habilitar DLQ para manejo de errores
  create_dlq = true
  
  # Configuración conservadora de reintentos
  maximum_retry_attempts        = 1
  maximum_event_age_in_seconds  = 3600  # 1 hora
  
  # Retención corta en DLQ para datos sensibles
  dlq_message_retention_seconds = 86400  # 1 día
}
```

### Cumplimiento Normativo

- **GDPR**: Configuración de retención de datos apropiada
- **SOX**: Auditoría completa de eventos y cambios
- **HIPAA**: Cifrado y controles de acceso estrictos
- **PCI DSS**: Monitoreo y logging de transacciones

## Observaciones

### Limitaciones Conocidas

1. **Límites de AWS EventBridge**
   - Máximo 300 reglas por bus de eventos
   - Tamaño máximo de evento: 256 KB
   - Límite de rate: 10,000 eventos por segundo por región

2. **Consideraciones de Costos**
   - Costo por evento procesado
   - Costos adicionales de DLQ (SQS)
   - Costos de invocación de Lambda

3. **Latencia**
   - EventBridge no garantiza orden de eventos
   - Latencia típica: pocos segundos
   - Para casos de uso de baja latencia, considerar alternativas

### Recomendaciones de Uso

1. **Monitoreo**
   - Configurar alarmas de CloudWatch para eventos fallidos
   - Monitorear métricas de DLQ
   - Establecer dashboards de observabilidad

2. **Testing**
   - Probar patrones de eventos en entornos de desarrollo
   - Validar expresiones cron antes del despliegue
   - Implementar tests de integración

3. **Mantenimiento**
   - Revisar regularmente reglas no utilizadas
   - Optimizar patrones de eventos para rendimiento
   - Actualizar funciones Lambda target regularmente

### Troubleshooting Común

1. **Eventos no se procesan**
   - Verificar permisos de Lambda
   - Validar patrones de eventos
   - Revisar logs de CloudWatch

2. **Funciones Lambda no se ejecutan**
   - Confirmar ARN de función correcta
   - Verificar que la función existe en la región
   - Revisar políticas de IAM

3. **Problemas con DLQ**
   - Verificar configuración de retry policy
   - Revisar permisos de SQS
   - Monitorear métricas de DLQ

### Roadmap y Mejoras Futuras

- Soporte para targets adicionales (SNS, SQS, Step Functions)
- Integración con AWS X-Ray para tracing
- Soporte para EventBridge Schema Registry
- Plantillas de patrones de eventos comunes
- Integración con AWS Config para compliance

---

**Versión del Módulo**: 1.0.0  
**Última Actualización**: 2024  
**Mantenido por**: CloudOps Team
