#!/bin/bash
ip link add macvlan-host link bridge0 type macvlan mode bridge
ip addr add 192.168.50.3/24 dev macvlan-host
ip link set macvlan-host up
ip route add 192.168.50.2/32 dev macvlan-host