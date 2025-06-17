#!/bin/bash
sudo ip link add macvlan-host link bridge0 type macvlan mode bridge
sudo ip addr add 192.168.50.3/24 dev macvlan-host
sudo ip link set macvlan-host up
sudo ip route add 192.168.50.2/32 dev macvlan-host