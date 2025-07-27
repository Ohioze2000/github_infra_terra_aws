#
variable "vpc_cidr_block"{
  type = string
  description = "VPC CIDR BLOCK"
}
variable "env_prefix"{
  type = string
  description = "ENVIRONMENT PREFIX"
}
variable "az_count" {
  default = 2
  type = number
}
variable "my_ip"{
  type = string
  description = "MY IP"
}
variable "instance_type"{
  type = string
  description = "INSTANCE TYPE"
}
variable "public_key_content"{
  type = string
  description = "The raw content of the public SSH key."
}
variable "domain_name"{
  description = "The root domain name to register (must already be registered with a registrar)"
  type        = string
}

variable "image_name" {
  type        = string  # <-- Added type declaration
  description = "The AMI ID or name to use for the EC2 instances." # <-- Added a helpful description
}

#variable "server_id" {}

#variable "alb_id" {}

#variable "cert_id" {}

#variable "certval_id" {}
#