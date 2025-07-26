#
variable "env_prefix"{
  type = string
  description = "ENVIRONMENT PREFIX"
}

variable "vpc_id" {}

variable "my_ip" {}

#variable "server_id" {}

#variable "subnet_id" {}

variable "instance_ids" {
  description = "List of EC2 instance IDs to attach to the ALB target group"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for the HTTPS listener."
  type        = string
}