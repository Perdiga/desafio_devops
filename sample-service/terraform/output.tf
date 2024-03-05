output "build_trigged_by" {
  value = null_resource.build.triggers
}

output "push_trigged_by" {
  value = null_resource.build.triggers
}