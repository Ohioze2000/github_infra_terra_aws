variable "env_prefix"{
  type = string
  description = "ENVIRONMENT PREFIX"
}

variable "instance_ids" {
  description = "A list of EC2 instance IDs for which monitoring should be configured."
  type        = list(string)
}

#variable "server_id" {}