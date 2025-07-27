#
variable "domain_name"{
  description = "The root domain name to register (must already be registered with a registrar)"
  type        = string
}

#variable "validation_record_fqdns" { 
#  description = "The FQDNs of the DNS records required for ACM certificate validation."
#  type        = list(string)
#}

#variable "certval_id" {}