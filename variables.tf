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
