terraform {
  backend "consul" {
    address = "consul.service.consul:8500"
    scheme  = "http"
    path    = "terraform/digitalocean/hashi-cluster"
  }
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.21.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.8.0"
    }
  }
}


provider "vault" {

}
data "vault_generic_secret" "do_token" {
  path = "kv/do"
}

provider "digitalocean" {
  token             = data.vault_generic_secret.do_token.data["token"]
  spaces_access_id  = data.vault_generic_secret.do_token.data["access_key_hashi_at_home"]
  spaces_secret_key = data.vault_generic_secret.do_token.data["secret_key_hashi_at_home"]
}

module "vpc" {
  source   = "brucellino/vpc/digitalocean"
  version  = "1.0.0"
  vpc_name = var.vpc
  project  = var.project
}

module "consul" {
  source                   = "brucellino/consul/digitalocean"
  version                  = "1.0.4"
  vpc                      = var.vpc
  depends_on               = [module.vpc]
  project_name             = var.project.name
  servers                  = 3
  ssh_inbound_source_cidrs = ["130.25.160.46"]
}
