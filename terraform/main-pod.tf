resource "kubernetes_pod" "hello-pod" {
  metadata {
    name      = "${var.app_name}-server"
    namespace = var.namespace
    labels    = local.pod_labels
  }

  spec {
    share_process_namespace = true

    # The container that runs the 'hello, world' application
    container {
      image = "docker.io/hammingweight/hello_server:${var.app_version}"
      name  = "${var.app_name}-server"

      port {
        container_port = 8000
      }
    }

    # A FIM sidecar container that checks if the index.html file of
    # the 'hello, world' application has been modified.
    container {
      image = "docker.io/hammingweight/fim:${var.fim_version}"
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
