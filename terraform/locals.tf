locals {
  pod_labels = {
    "app.kubernetes.io/name" : var.app_name
    "app.kubernetes.io/instance" : var.app_name
    "app.kubernetes.io/version" : var.app_version
  }
}
