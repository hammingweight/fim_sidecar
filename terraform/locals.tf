locals {
  # The labels on the "hello" app pod that are used to
  # select the pod by a load balancer.
  pod_labels = {
    "app.kubernetes.io/name" : var.app_name
    "app.kubernetes.io/instance" : var.app_name
    "app.kubernetes.io/version" : var.app_version
  }
}
