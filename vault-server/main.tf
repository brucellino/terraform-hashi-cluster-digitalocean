terraform {
  backend "consul" {
    scheme = "http"
    path   = "terraform/digitalocean/hashi-cluster/vault-server"
  }
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3"
    }
  }
}

provider "vault" {
  token              = "hvs.0i6l86Uvm4NmaRHaYcKWlHhM"
  address            = "https://vault.brusiceddu.xyz"
  add_address_to_env = true
}

module "vault_server" {
  vault_addr = "https://vault.brusisceddu.xyz"
  source     = "../../../../../vaultatho.me/"
  # version = "1.7.0"
  # ssh_inbound_source_cidrs = ["2.38.151.8"]
}
