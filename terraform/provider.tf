provider "kubernetes" {
  config_path    = var.kube_config_path
  config_context = var.kube_config_context
}
