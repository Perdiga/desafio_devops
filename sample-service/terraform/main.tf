terraform {
  backend "s3" {
    bucket = "mateusfer.tfstate"
    key    = "challange/sample-service.tfstate"
    region = "us-east-1"
  }

  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.ecr.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.ecr.outputs.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.ecr.outputs.cluster_name]
    command     = "aws"
  }
}

data "aws_caller_identity" "current" {}
data "terraform_remote_state" "ecr" {
  backend = "s3"

  config = {
    bucket = "mateusfer.tfstate"
    key    = "challange/k8s.tfstate"
    region = "us-east-1"
  }
}

locals {
  timestream_database_name = "ChallangeDB"
  timestamp                = timestamp()
  image_name               = "sample-service"
  image_tag                = "latest"
  force_image_rebuild      = true

  docker_img_src_path   = "${path.module}/src"
  docker_img_src_sha256 = sha256(join("", [for f in fileset(".", "${local.docker_img_src_path}/**") : filebase64(f)]))

  tags = {
    Application = "Challange"
    CreatedBy   = "Mateus - Test"
    DeployedBy  = data.aws_caller_identity.current.arn
    Environment = "nonprod"
    Repository  = "https://github.com/Perdiga/desafio_ilia"
  }
}
