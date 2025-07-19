variable "public_key_location"{
  type = string
  description = "PUBLIC KEY LOCATION"
}

variable "az_count" {
  default = 2
  type = number
}

variable "instance_type"{
  type = string
  description = "INSTANCE TYPE"
}

variable "env_prefix"{
  type = string
  description = "ENVIRONMENT PREFIX"
}

variable "subnet_id" {}

variable "image_name" {
    
}