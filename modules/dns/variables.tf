#
variable "domain_name"{
  description = "The root domain name to register (must already be registered with a registrar)"
  type        = string
}

#variable "hosted_zone_id" {
#  description = "The ID of your Route 53 Hosted Zone for your domain."
#  type        = string
#}

variable "alb_dns_name" {
  description = "The DNS name of the ALB to point records to."
  type        = string
}

variable "alb_zone_id" {
  description = "The Route 53 Hosted Zone ID of the Application Load Balancer."
  type        = string
}

variable "acm_domain_validation_options" {
  description = "Domain validation options from the ACM certificate for DNS record creation."
  type = list(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_type  = string
    resource_record_value = string
  }))
}

#variable "certificate_domain_name" {
#  description = "The primary domain name of the ACM certificate."
#  type        = string
#}

variable "env_prefix" {
  description = "Prefix for resources created by the DNS module."
  type        = string
}

#variable "public_subnet_ids" {
#  description = "List of public subnet IDs (e.g., for Route 53 Resolver endpoints, if used)."
#  type        = list(string)
#  default     = [] # Use a default if it's optional, or ensure it's always passed.
#}

#variable "private_subnet_ids" {
#  description = "List of private subnet IDs (e.g., for Route 53 Resolver endpoints, if used)."
#  type        = list(string)
#  default     = [] # Use a default if it's optional, or ensure it's always passed.
#}

#variable "certificate_arn" {
#  description = "The ARN of the ACM certificate to validate."
#  type        = string
#}


#variable "alb_id" {}

#variable "cert_id" {}

