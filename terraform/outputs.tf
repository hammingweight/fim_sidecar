output "service_endpoint" {
  value = try(
    "http://${kubernetes_service.hello.status[0]["load_balancer"][0]["ingress"][0]["ip"]}:${var.service_port}",
  "(error getting service_endpoint address)")
}
