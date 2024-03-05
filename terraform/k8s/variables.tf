variable "region" {
  description = "Region to deploy application"
  default     = "us-east-1"
}

variable "eks_node_group_capacity_type" {
  description = "Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT"
  default     = "ON_DEMAND"
}

variable "eks_node_group_instance_types" {
  description = "List of instance types associated with the EKS Node Group. Check and make sure that your workload is supported by your instance type https://www.middlewareinventory.com/blog/kubernetes-max-pods-per-node/"
}

variable "scaling_config_desired_size" {
  description = "Desired number of worker nodes."
}

variable "scaling_config_max_size" {
  description = "Maximum number of worker nodes."
}

variable "scaling_config_min_size" {
  description = "Minimum number of worker nodes."
}

variable "update_confige_max_unavailable" {
  description = "Desired max number of unavailable worker nodes during node group update."
}


