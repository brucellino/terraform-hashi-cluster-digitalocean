variable "do_vault_mount" {
  type        = string
  default     = "digitalocean"
  description = "Path of the mount in Vault where the DigitalOCean terraform token is kept."
}
variable "cf_vault_mount" {
  type        = string
  default     = "cloudflare"
  description = "Path of the mount in Vault where cloudflare terraform token is kept."
}
variable "domain" {
  type        = string
  description = "Domain we are deploying into"
  default     = "brucellino.dev"
}

variable "vpc" {
  type        = string
  description = "Name of the DigitalOcean VPC"
  default     = "hashi"
}

variable "project" {
  type        = map(string)
  description = "Project configuration"
  default = {
    name        = "HashiDo"
    description = "Hashi cluster"
    purpose     = "Personal"
    environment = "development"
  }
}
