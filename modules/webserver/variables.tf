variable "vpc_id" {}

variable "env_prefix"{
  type = string
  description = "ENVIRONMENT PREFIX"
}

variable "az_count" {
  default = 2
  type = number
}

variable "public_key_location"{
  type = string
  description = "PUBLIC KEY LOCATION"
}

variable "image_name" {}

variable "instance_type"{
  type = string
  description = "INSTANCE TYPE"
}

variable "subnet_id" {}