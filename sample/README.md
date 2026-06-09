# Ejemplo de Uso — EventBridge Module

Este directorio contiene un ejemplo funcional de cómo consumir el módulo `cloudops-ref-repo-aws-eventbridge-terraform`.

## Patrón de Transformación (PC-IAC-026)

```
terraform.tfvars  →  variables.tf  →  locals.tf  →  main.tf  →  module
```

## Pre-requisitos

- Terraform >= 1.0.0
- AWS CLI configurado con perfil apropiado
- Las funciones Lambda referenciadas deben existir previamente

## Recursos que crea

- `aws_cloudwatch_event_rule` — reglas de EventBridge (event pattern y/o scheduled)
- `aws_cloudwatch_event_target` — targets Lambda o SNS
- `aws_lambda_permission` — permisos para que EventBridge invoque Lambda

## Ejecución

```bash
cd sample/

terraform init \
  -backend-config="bucket=mi-bucket-estado" \
  -backend-config="key=eventbridge/dev/terraform.tfstate" \
  -backend-config="region=us-east-1"

terraform plan  -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```
