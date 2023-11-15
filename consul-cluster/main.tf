terraform {
  backend "consul" {
    scheme = "http"
    path   = "terraform/digitalocean/hashi-cluster/consul-cluster"
  }
  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2"
    }
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
      version = ">= 4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
  }
}

variable "do_vault_mount" {
  type        = string
  default     = "digitalocean"
  description = "Path of the mount in Vault where the DigitalOCean terraform token is kept."
}
variable "cf_vault_mount" {
  type        = string
  default     = "cloudflare"
  description = "Path of the mount in Vault where cloudflare terraform token is kept."
}

provider "vault" {}
provider "consul" {}

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
}

data "consul_keys" "config" {
  key {
    path = "do/hashi_cluster"
    name = "config"
  }
}

provider "vault" {
  token              = "hvs.0i6l86Uvm4NmaRHaYcKWlHhM"
  address            = "https://vault.brusiceddu.xyz"
  add_address_to_env = true
  alias              = "do"
}

data "digitalocean_vpc" "selected" {
  name = yamldecode(data.consul_keys.config.var.config).vpc_name
}

data "digitalocean_project" "selected" {
  name = yamldecode(data.consul_keys.config.var.config).project.name
}

module "consul_cluster" {
  # source = "github.com/brucellino/terraform-digitalocean-consul"
  source         = "../../../../modules/terraform-digitalocean-consul/"
  vpc_name       = data.digitalocean_vpc.selected.name
  project_name   = data.digitalocean_project.selected.name
  agents         = 3
  servers        = 3
  consul_version = "1.16.3"
  # ssh_inbound_source_cidrs = ["2.38.151.8"]
}
