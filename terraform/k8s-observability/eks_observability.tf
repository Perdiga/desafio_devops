##### Update kubeconfig #####
# TODO: Não deveria precisar fazer isso por estou usando os providers
resource "null_resource" "kubectl" {
    provisioner "local-exec" {
        command = "aws eks --region ${var.region} update-kubeconfig --name ${data.terraform_remote_state.eks.outputs.cluster_name}"
    }
}

##### Namespace #####
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = local.observability_namespace
  }

  depends_on = [null_resource.kubectl]
}

##### Manage CRDs #####
data "http" "yaml_file" {
  for_each = toset(local.crds_urls)
  
  url      = each.value
}

resource "null_resource" "status_check" {
  for_each = toset(local.crds_urls)

  provisioner "local-exec" {
    command = contains([200, 201, 204], data.http.yaml_file[each.value].status_code)
  }

  depends_on = [null_resource.kubectl]
}

resource "kubectl_manifest" "crd" {
  for_each = toset(local.crds_urls)

  yaml_body  = data.http.yaml_file[each.value].response_body

  force_new         = local.crds_force_new
  server_side_apply = local.crds_server_side_apply
  force_conflicts   = local.crds_force_conflicts
  apply_only        = local.crds_apply_only

  depends_on = [null_resource.status_check,null_resource.kubectl]
}


##### Prometheus Stack (Prometheus + Grafana) #####

resource "helm_release" "prometheus" {
  chart      = "kube-prometheus-stack"
  name       = "kube-prometheus-stack"
  namespace  = local.observability_namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = local.chart_version

  skip_crds = true

  depends_on = [kubectl_manifest.crd, null_resource.kubectl]
}
