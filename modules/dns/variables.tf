#
variable "domain_name"{
  description = "The root domain name to register (must already be registered with a registrar)"
  type        = string
}

variaable "alb_id" {}

variable "cert_id" {}