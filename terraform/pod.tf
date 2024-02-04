resource "kubernetes_pod" "hello-pod" {
  metadata {
    name   = "hello"
    labels = local.pod_labels
  }

  spec {
    share_process_namespace = true
    container {
      image = "docker.io/hammingweight/hello_server:1.0.0"
      name  = "hello-server"

      port {
        container_port = 8000
      }
    }
    container {
      image = "docker.io/hammingweight/fim:1.0.0"
      name  = "fim"
      security_context {
        capabilities {
          drop = ["ALL"]
          add  = ["DAC_READ_SEARCH", "KILL", "SYS_PTRACE"]
        }
      }
      liveness_probe {
        exec {
          command = ["/bin/ash", "/healthz", "/home/hellouser/index.html", "746308829575e17c3331bbcb00c0898b"]
        }
      }
    }
  }
}
