resource "kubernetes_service" "hello" {
  metadata {
    name      = "${var.app_name}-service"
    namespace = var.namespace
    labels    = local.service_labels
  }
  spec {
    selector = local.pod_labels
    port {
      port        = var.service_port
      target_port = 8000
    }

    type = "LoadBalancer"
  }
}
