variable "app_version" {
  description = "The version of the 'hello' application."
  type        = string
  default     = "1.0.0"
}

variable "fim_version" {
  description = "The version of the FIM sidecar image."
  type        = string
  default     = "1.0.0"
}

variable "service_port" {
  description = "The port exposed by the 'hello' service."
  type        = number
  default     = 80
}
