#
variable "env_prefix"{
  type = string
  description = "ENVIRONMENT PREFIX"
}

variable "vpc_id" {
  description = "The ID of the VPC where the ALB will be deployed."
  type        = string # Added type declaration
}

#variable "my_ip" {
#  description = "The IP address or CIDR block allowed to access the ALB on HTTP/HTTPS. Use '0.0.0.0/0' for public access."
#  type        = string # Added type declaration
#}

variable "subnet_ids" {
  description = "A list of subnet IDs where the ALB will be deployed."
  type        = list(string)
}

#variable "server_id" {}

#variable "subnet_id" {}

#variable "hosted_zone_id" {
#  description = "The ID of the Route 53 Hosted Zone where the ALB's DNS record will be created."
#  type        = string
#}

#variable "domain_name" {
#  description = "The root domain name (e.g., example.com) for the ALB's DNS record."
#  type        = string
#}

variable "instance_ids" {
  description = "List of EC2 instance IDs to attach to the ALB target group"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for the HTTPS listener."
  type        = string
}