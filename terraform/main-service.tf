resource "kubernetes_service" "hello" {
  metadata {
    name      = "hello"
    namespace = var.namespace
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
