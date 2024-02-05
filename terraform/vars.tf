variable "app_name" {
  description = "The name of the application."
  type        = string
  default     = "hello"
}

variable "app_version" {
  description = "The version of the application."
  type        = string
  default     = "1.0.0"
}

variable "fim_version" {
  description = "The version of the FIM sidecar image."
  type        = string
  default     = "1.0.0"
}

variable "service_port" {
  description = "The port exposed by the service."
  type        = number
  default     = 80
}

variable "namespace" {
  description = "The namespace of the application."
  type        = string
  default     = "default"
}
