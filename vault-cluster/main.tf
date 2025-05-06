terraform {
  backend "consul" {
    # address = "consul.service.consul:8500"
    scheme = "http"
    path   = "terraform/digitalocean/hashi-cluster/vault"
  }
  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = ">= 2"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3"
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

provider "consul" {}
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
  token = data.vault_kv_secret_v2.do.data["terraform"]
  # spaces_access_id  = data.vault_kv_secret_v2.do.data["spaces_key"]
  # spaces_secret_key = data.vault_kv_secret_v2.do.data["spaces_secret"]
}

data "consul_keys" "config" {
  key {
    path = "do/hashi_cluster"
    name = "config"
  }
}

data "digitalocean_vpc" "selected" {
  name = yamldecode(data.consul_keys.config.var.config).vpc_name
}

data "digitalocean_project" "selected" {
  name = yamldecode(data.consul_keys.config.var.config).project.name
}

module "vault" {
  instances        = 1
  source           = "brucellino/vault/digitalocean"
  version          = "3.0.0"
  vpc_name         = data.digitalocean_vpc.selected.name
  project_name     = data.digitalocean_project.selected.name
  vault_version    = "1.15.1"
  region           = yamldecode(data.consul_keys.config.var.config).region
  region_from_data = false
  # ssh_inbound_source_cidrs = ["2.38.151.8"]
}
