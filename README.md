# Terraform Hashi Cluster -- Digital Ocean

A Hashicorp (Vault, Consul, Nomad) cluster on Digital Ocean.

This builds a "bedrock" cluster for Hashicorp products (Vault, Consul, Nomad) on Digital Ocean.

A bedrock cluster is the server configuration with zero dependencies, which can be used as a foundation for other clusters in a federation, or scaled out with agent pools.
It is necessary to have a bedrock configuration in order to break circular dependencies on configuration, and have a clear directed graph of deployment.

## Design

This Terraform configuration is designed to use independent Terraform modules created and maintained upstream, in order to iterate from one state to the next in a prescribed manner.

These are, in order:

1. Networking
2. Vault servers
3. Consul + Nomad servers

### Networking

The first resource necessary is the cloud private network.
In this case, we are deploying into Digital Ocean, but similar principles apply in other cloud providers such as OpenStack.
A virtual private network is necessary to create the private interfaces for the Vault services to bind to and co-ordinate.
This also provides the ability close the service off from the public internet.
The VPC module used in this configuration includes integration with Tailscale for private networking.
