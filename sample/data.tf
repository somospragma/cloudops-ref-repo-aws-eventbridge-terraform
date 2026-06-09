# Data sources del ejemplo
# PC-IAC-011: Data sources para obtener IDs dinámicos
# Descomentar según necesidad del ambiente de prueba

# data "aws_caller_identity" "current" {
#   provider = aws.principal
# }

# data "aws_lambda_function" "target" {
#   provider      = aws.principal
#   function_name = "nombre-de-la-lambda-existente"
# }
