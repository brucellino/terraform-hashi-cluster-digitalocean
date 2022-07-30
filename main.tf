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
  source   = "../../../modules/terraform-module-digitalocean-vpc/"
  vpc_name = "hashi"
  project = {
    name        = "Hashi stuff"
    description = "A hashi cluster (Vault, Consul, Vault) with some nodes"
    purpose     = "Product development"
    environment = "development"
  }
}

module "vault" {
  source       = "../../../modules/terraform-module-digitalocean-vault/"
  depends_on   = [module.vpc]
  vpc_name     = "hashi"
  project_name = "Hashi stuff"
}
