locals {
  pod_labels = {
    "app.kubernetes.io/name" : "hello"
    "app.kubernetes.io/instance" : "hello"
    "app.kubernetes.io/version" : "1.0.0"
  }
}
