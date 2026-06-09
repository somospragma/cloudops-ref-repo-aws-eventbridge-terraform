##############################################################################
# sample/providers.tf
# PC-IAC-005: alias = "principal" en el Root, inyectado como aws.project al módulo
# PC-IAC-004: default_tags para tags transversales de gobernanza
##############################################################################
provider "aws" {
  alias  = "principal"
  region = "us-east-1"

  # En pipeline: assume_role con deploy_role_arn
  # assume_role {
  #   role_arn = var.deploy_role_arn
  # }

  default_tags {
    tags = {
      client      = "pragma"
      project     = "eventbridge-sample"
      environment = "dev"
      provisioned = "terraform"
    }
  }
}

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.31.0"
    }
  }
  # PC-IAC-008: Backend vacío - los atributos se inyectan en el pipeline
  backend "s3" {}
}
