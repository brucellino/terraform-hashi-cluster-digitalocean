terraform {
  backend "consul" {
    # address = "consul.service.consul:8500"
    scheme = "http"
    path   = "terraform/digitalocean/hashi-cluster"
  }
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.28.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.17.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.9"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
  }
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
  source     = "brucellino/vpc/digitalocean"
  version    = "1.0.3"
  vpc_name   = var.vpc
  project    = var.project
  vpc_region = "ams3"
}

module "vault" {
  depends_on               = [module.vpc]
  source                   = "brucellino/vault/digitalocean"
  version                  = "1.2.1"
  vpc_name                 = var.vpc
  project_name             = var.project.name
  ssh_inbound_source_cidrs = ["2.38.151.8"]
}

# module "consul" {
#   source  = "brucellino/consul/digitalocean"
#   version = "1.0.7"
#   # vpc                      = var.vpc
#   depends_on               = [module.vpc]
#   project_name             = var.project.name
#   servers                  = 3
#   ssh_inbound_source_cidrs = ["130.25.160.46"]
# }
