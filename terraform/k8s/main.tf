terraform {
  # INFO: As melhores praticas incluem a criação de um state lock no Dynamo DB, 
  #       versionamento e criptografia do arquivo. Não estão sendo feitas aqui. 
  backend "s3" {
    bucket = "mateusfer.tfstate"
    key    = "challange/k8s.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  ecr_name    = "challange-ecr"
  cluster_name    = "challange-eks"
  vpc_name        = "challange-vpc"
  node_group_name = "private-nodes"

  tags = {
    Application = "Challange"
    CreatedBy   = "Mateus"
    DeployedBy  = data.aws_caller_identity.current.arn
    Environment = "nonprod"
    Repository  = "https://github.com/Perdiga/desafio_devops"
  }
}
