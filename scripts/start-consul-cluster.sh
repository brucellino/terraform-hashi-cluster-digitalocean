#!/bin/bash
set -eou pipefail
n_servers=$(terraform output -json server_public_ips | jq '.|length')
n_agents=$(terraform output -json agent_public_ips | jq '.|length')
for node in $(seq 0 $(( n_servers - 1))) ; do
  IP=$(terraform output -json server_public_ips | jq -r --arg n "${node}" '.[$n|tonumber]')
  ssh -oStrictHostKeyChecking=no root@"${IP}" 'service consul start'
done

# This will connect to the servers and start the consul service.
for node in $(seq 0 $(( n_servers - 1 ))) ; do
  IP=$(terraform output -json server_public_ips | jq -r --arg n "${node}" '.[$n|tonumber]')
  ssh -oStrictHostKeyChecking=no root@"${IP}" 'consul members'
done

for node in $(seq 0 $(( n_agents - 1 ))) ; do
  IP=$(terraform output -json agent_public_ips | jq -r --arg n "${node}" '.[$n|tonumber]')
  echo "Starting consul on agent ${node}"
  ssh -oStrictHostKeyChecking=no root@"${IP}" 'service consul start'
done
