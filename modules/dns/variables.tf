#
variable "domain_name"{
  description = "The root domain name to register (must already be registered with a registrar)"
  type        = string
}

variable "hosted_zone_id" {
  description = "The ID of your Route 53 Hosted Zone for your domain."
  type        = string
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB to point records to."
  type        = string
}

variable "alb_zone_id" {
  description = "The hosted zone ID of the ALB (for Route 53 Alias record)."
  type        = string
}

#variable "alb_id" {}

#variable "cert_id" {}

