# output "server_public_ips" {
#   description = "List of public IPs for the Consul servers"
#   value       = module.consul.server_public_ips
# }
# output "agent_public_ips" {
#   description = "List of public IPs for the Consul agents"
#   value       = module.consul.agent_public_ips
# }

# output "lb_ip" {
#   description = "URL of the load balancer fronting the servers"
#   value       = join("", ["http://", module.consul.load_balancer_ip])
# }
