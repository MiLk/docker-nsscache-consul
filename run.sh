#!/usr/bin/env bash

docker-compose up -d

ssh_port=$(docker-compose port nsscache 22 | cut -d':' -f2)
consul_port=$(docker-compose port consul 8500 | cut -d':' -f2)

curl -sS -XPUT http://127.0.0.1:${consul_port}/v1/kv/bastion/group/bar/gid -d '5000' >/dev/null
curl -sS -XPUT http://127.0.0.1:${consul_port}/v1/kv/bastion/passwd/foo/uid -d '10000' >/dev/null
curl -sS -XPUT http://127.0.0.1:${consul_port}/v1/kv/bastion/passwd/foo/gid -d '5000' >/dev/null
curl -sS -XPUT http://127.0.0.1:${consul_port}/v1/kv/bastion/passwd/foo/comment -d 'Foo Bar' > /dev/null
curl -sS -XPUT http://127.0.0.1:${consul_port}/v1/kv/bastion/shadow/foo/lstchg -d '17313' >/dev/null

ssh_run () {
  user=${1}
  shift 1
  ssh ${user}@127.0.0.1 -p ${ssh_port} -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' -i ./nsscache/root "${@}"
}

echo "Updating the cache..."
ssh_run root '/usr/local/bin/nsscache update'
echo
echo "Listing the cache files..."
ssh_run root 'ls /etc/{group,passwd,shadow}.*'
echo
echo "Checking the foo account"
ssh_run root 'getent passwd foo'
echo
echo "Connecting as foo..."
ssh_run foo 'id'
echo

