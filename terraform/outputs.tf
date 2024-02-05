output "service_endpoint" {
  description = "The endpoint that the user should use to invoke the 'hello' application."
  value = try(
    "http://${kubernetes_service.hello.status[0]["load_balancer"][0]["ingress"][0]["ip"]}:${var.service_port}",
  "(error getting service_endpoint address)")
}
