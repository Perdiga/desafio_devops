output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "ecr_repository_url" {
  description = "- The URL of the repository (in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName)"
  value       = aws_ecr_repository.ecr.repository_url
}

output "ecr_uri" {
  description = "- The URI of the ecr (in the form aws_account_id.dkr.ecr.region.amazonaws.com)"
  value       = "${var.aws_account}.dkr.ecr.${var.region}.amazonaws.com"
}
