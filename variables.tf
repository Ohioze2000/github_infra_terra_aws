variable VPC_CIDR_BLOCK{}
variable ENV_PREFIX{}
variable "az_count" {
  default = 2
  type = number
}
variable MY_IP{}
variable INSTANCE_TYPE{}
variable PUBLIC_KEY_LOCATION {}
variable "DOMAIN_NAME" {
  description = "The root domain name to register (must already be registered with a registrar)"
  type        = string
}