terraform {
  backend "consul" {
    scheme = "http"
    path   = "terraform/digitalocean/hashi-cluster/vpc"
  }
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2"
    }
  }
}

provider "consul" {}

variable "do_vault_mount" {
  description = "Path to the Vault mount for the Digital Ocean Secrets"
  type        = string
  default     = "digitalocean"
  sensitive   = false
}

provider "vault" {}

data "vault_kv_secret_v2" "do" {
  mount = var.do_vault_mount
  name  = "tokens"
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

module "vpc" {
  source     = "brucellino/vpc/digitalocean"
  version    = "1.0.3"
  vpc_name   = yamldecode(data.consul_keys.config.var.config).vpc_name
  project    = yamldecode(data.consul_keys.config.var.config).project
  vpc_region = yamldecode(data.consul_keys.config.var.config).region
}
