resource "kubernetes_service" "hello" {
  metadata {
    name = "hello"
  }
  spec {
    selector = local.pod_labels
    port {
      port        = 80
      target_port = 8000
    }

    type = "LoadBalancer"
  }
}
