resource "null_resource" "build" {
  triggers = {
    # Garante que você consiga fazer a forçar a publicação da imagem 
    detect_docker_source_changes = local.force_image_rebuild == true ? timestamp() : local.docker_img_src_sha256
  }
  provisioner "local-exec" {
    command = <<-EOT
        cd ..

        docker build -t ${local.image_name}:${local.image_tag} . \
            --build-arg AWS_ACCESS_KEY_ID=${var.AWS_ACCESS_KEY_ID} \
            --build-arg AWS_SECRET_ACCESS_KEY=${var.AWS_SECRET_ACCESS_KEY} \
            --build-arg AWS_DEFAULT_REGION=${var.region}
    EOT
  }
}

resource "null_resource" "push" {
  triggers = {
    # Garante que você consiga fazer a forçar a publicação da imagem 
    detect_docker_source_changes = local.force_image_rebuild == true ? timestamp() : local.docker_img_src_sha256
  }
  provisioner "local-exec" {
    command = <<-EOT
        aws ecr get-login-password --region ${var.region} | \
            docker login --username AWS --password-stdin ${data.terraform_remote_state.ecr.outputs.ecr_uri}
        
        docker tag ${local.image_name}:${local.image_tag} ${data.terraform_remote_state.ecr.outputs.ecr_repository_url}:${local.image_tag}

        docker push ${data.terraform_remote_state.ecr.outputs.ecr_repository_url}:${local.image_tag}
    EOT
  }
  depends_on = [ null_resource.build ]
}

resource "kubectl_manifest" "deploy" {
    yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-service
  labels:
    app: sample-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sample-service
  template:
    metadata:
      labels:
        app: sample-service
    spec:
      containers:
        - name: sample-service-container
          image: ${data.terraform_remote_state.ecr.outputs.ecr_repository_url}:${local.image_tag}
          imagePullPolicy: Always

YAML

    depends_on = [ null_resource.build,null_resource.push ]
} 
