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
  mount    = "hashiatho.me-v2"
  name     = "tailscale"
}

provider "digitalocean" {
  token = data.vault_kv_secret_v2.do_token.data.terraform
}

provider "tailscale" {
  api_key = data.vault_kv_secret_v2.tailscale.data.tailscale_api_token
}

module "vpc" {
  source          = "brucellino/vpc/digitalocean"
  version         = "~> 2"
  project         = var.project
  vpc_name        = var.vpc.name
  vpc_region      = "ams3"
  vpc_description = var.vpc.description
}

module "vault" {
  # Creates a vault that must be manually initialized and unsealed
  source                   = "brucellino/vault/digitalocean"
  version                  = "~> 3"
  count                    = 1
  instances                = 3
  create_instances         = true
  ssh_inbound_source_cidrs = ["151.74.209.108/24"]
  droplet_size             = "s-1vcpu-1gb"
  # deploy_zone  = "brusisceddu.xyz"
  project_name = var.project.name
  vpc_name     = var.vpc.name
  depends_on   = [module.vpc]
}
