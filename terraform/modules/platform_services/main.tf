variable "service_files" {
  description = "critical path cluster service definitions"
  type = list(string)
  default = [
    "calico-vxlan.yaml",
    "configmap_coredns.yaml",
    "cluster-autoscaler-run-on-master.yaml",
    "ingress.yaml",
    "canary.yaml"
  ]
}
resource "aws_s3_bucket_object" "s3_core_service_files" {
  bucket = "${var.cluster_name}-lockbox"
  count = length(var.service_files)
  source = "${path.module}/files/${var.service_files[count.index]}"
  etag = filemd5("${path.module}/files/${var.service_files[count.index]}")
  key = "manifests/${var.service_files[count.index]}"
}


    
