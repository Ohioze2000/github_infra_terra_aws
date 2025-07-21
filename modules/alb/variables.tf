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
variable "public_key_location"{
  type = string
  description = "PUBLIC KEY LOCATION"
}
variable "domain_name"{
  description = "The root domain name to register (must already be registered with a registrar)"
  type        = string
}

variable "vpc_id" {}