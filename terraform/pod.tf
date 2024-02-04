resource "kubernetes_pod" "hello-pod" {
  metadata {
    name   = "hello"
    labels = local.pod_labels
  }

  spec {
    container {
      image = "docker.io/hammingweight/hello_server:1.0.0"
      name  = "hello-server"

      port {
        container_port = 8000
      }
    }
  }
}
