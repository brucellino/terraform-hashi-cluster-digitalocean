provider "vault" {
  # The hashi@home vault provider is used to provide secrets to other provider configurations
  alias   = "athome"
  address = "http://active.vault.service.consul:8200"
}

data "vault_kv_secret_v2" "do_token" {
  provider = vault.athome
  mount    = "digitalocean"
  name     = "tokens"
}

data "vault_kv_secret_v2" "tailscale" {
  provider = vault.athome
  mount    = "digitalocean"
  name     = "tailscale"
}

provider "digitalocean" {
  token = data.vault_kv_secret_v2.do_token.data.terraform
}

provider "tailscale" {
  api_key = data.vault_kv_secret_v2.tailscale.data.api_key
}

module "vpc" {
  source          = "brucellino/vpc/digitalocean"
  version         = "~> 2"
  project         = var.project
  vpc_name        = var.vpc
  vpc_region      = "ams3"
  vpc_description = "My VPC Is El Raddissimo"
}

module "vault" {
  source       = "brucellino/vault/digitalocean"
  version      = "~> 3"
  count        = 3
  droplet_size = "s-1vcpu-1gb"
  deploy_zone  = "brusisceddu.xyz"
  project_name = var.project.name
  vpc_name     = var.vpc
  depends_on   = [module.vpc]
}
