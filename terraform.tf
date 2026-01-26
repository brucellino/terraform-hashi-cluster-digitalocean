terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.25.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }

  }
  required_version = "~> 1.14"
  backend "consul" {
    path = "terraform/digitalocean"
  }
}
