variable vpc_cidr_block{}
variable env_prefix{}
variable "az_count" {
  default = 2
  type = number
}
variable my_ip{}
variable instance_type{}
variable public_key_location {}
variable "domain_name" {
  description = "The root domain name to register (must already be registered with a registrar)"
  type        = string
}