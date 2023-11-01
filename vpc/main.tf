terraform {
  backend "consul" {
    scheme = "http"
    path   = "terraform/digitalocean/hashi-cluster/vpc"
  }
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
  }
}

variable "do_vault_mount" {
  description = "Path to the Vault mount for the Digital Ocean Secrets"
  type        = string
  default     = "digitalocean"
  sensitive   = false
}

variable "cf_vault_mount" {
  description = "Path to Vault mount for the Cloudflare secrets."
  type        = string
  default     = "cloudflare"
}

provider "vault" {}

data "vault_kv_secret_v2" "do" {
  mount = var.do_vault_mount
  name  = "tokens"
}

data "vault_kv_secret_v2" "cf" {
  mount = var.cf_vault_mount
  name  = "terraform"
}
provider "cloudflare" {
  api_token = data.vault_kv_secret_v2.cf.data["api_token"]
}

provider "digitalocean" {
  token             = data.vault_kv_secret_v2.do.data["terraform"]
  spaces_access_id  = data.vault_kv_secret_v2.do.data["spaces_key"]
  spaces_secret_key = data.vault_kv_secret_v2.do.data["spaces_secret"]
}

module "vpc" {
  source   = "brucellino/vpc/digitalocean"
  version  = "1.0.3"
  vpc_name = "hashicluster"
  project = {
    name        = "HashiDo"
    description = "Hashi cluster"
    purpose     = "Personal"
    environment = "development"
  }
  vpc_region = "ams3"
}
