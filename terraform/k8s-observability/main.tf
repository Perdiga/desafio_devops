terraform {
  # INFO: As melhores praticas incluem a criação de um state lock no Dynamo DB, 
  #       versionamento e criptografia do arquivo. Não estão sendo feitas aqui. 
  backend "s3" {
    bucket = "mateusfer.tfstate"
    key    = "challange/k8s-observability.tfstate"
    region = "us-east-1"
  }

  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }  
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "mateusfer.tfstate"
    key    = "challange/k8s.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_name]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_name]
    command     = "aws"
  }
}

locals {
  observability_namespace = "monitoring"

  chart_version = "56.20.1"
  crds_urls = [
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.chart_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-alertmanagerconfigs.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.chart_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-alertmanagers.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.chart_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-podmonitors.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.chart_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-probes.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.chart_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-prometheusagents.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.chart_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-prometheuses.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.chart_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-prometheusrules.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.chart_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-scrapeconfigs.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.chart_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-servicemonitors.yaml",
    "https://raw.githubusercontent.com/prometheus-community/helm-charts/kube-prometheus-stack-${local.chart_version}/charts/kube-prometheus-stack/charts/crds/crds/crd-thanosrulers.yaml"
  ]
  crds_force_new         = true
  crds_server_side_apply = true
  crds_force_conflicts   = true
  crds_apply_only        = false

  tags = {
    Application = "Challange"
    CreatedBy   = "Mateus"
    DeployedBy  = data.aws_caller_identity.current.arn
    Environment = "nonprod"
    Repository  = "https://github.com/Perdiga/desafio_devops"
  }
}
