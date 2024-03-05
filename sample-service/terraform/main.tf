terraform {
  backend "s3" {
    bucket = "mateusfer.tfstate"
    key    = "challange/sample-service.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  timestream_database_name = "ChallangeDB"

  tags = {
    Application = "Challange"
    CreatedBy   = "Mateus - Test"
    DeployedBy  = data.aws_caller_identity.current.arn
    Environment = "nonprod"
    Repository  = "https://github.com/Perdiga/desafio_ilia"
  }
}
