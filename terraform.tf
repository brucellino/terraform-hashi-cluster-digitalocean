terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
    tailscale = {
      source = "tailscale/tailscale"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }

  }
  required_version = "~> 1.11"
  backend "consul" {
    path = "terraform/digitalocean"
  }
}
