#!/bin/bash

# ネットワーク作成
docker network create ndn_network
docker network create ipfs_network

# NFDの接続
docker exec ipfs-sfc-blur-ndn-1 nfdc face create tcp4://ipfs-sfc-gray-ndn-1.ndn_network
docker exec ipfs-sfc-blur-ndn-1 nfdc route add / nexthop tcp4://ipfs-sfc-gray-ndn-1.ndn_network
docker exec ipfs-sfc-gray-ndn-1 nfdc face create tcp4://ipfs-sfc-blur-ndn-1.ndn_network
docker exec ipfs-sfc-gray-ndn-1 nfdc route add / nexthop tcp4://ipfs-sfc-blur-ndn-1.ndn_network

# csの削除
docker exec ipfs-sfc-blur-ndn-1 nfdc cs config capacity 0
docker exec ipfs-sfc-gray-ndn-1 nfdc cs config capacity 0

# IPFS (Kubo) の接続
while ! docker logs ipfs-sfc-blur-ipfs-1 | grep -q "Daemon is ready" ; do sleep 2 ; done
while ! docker logs ipfs-sfc-gray-ipfs-1 | grep -q "Daemon is ready" ; do sleep 2 ; done
IP_blur=$(docker inspect -f "{{.NetworkSettings.Networks.ipfs_network.IPAddress}}" ipfs-sfc-blur-ipfs-1)
IP_gray=$(docker inspect -f "{{.NetworkSettings.Networks.ipfs_network.IPAddress}}" ipfs-sfc-gray-ipfs-1)
peerID_blur=$(docker exec ipfs-sfc-blur-ipfs-1 ipfs id -f="<id>")
peerID_gray=$(docker exec ipfs-sfc-gray-ipfs-1 ipfs id -f="<id>")
docker exec ipfs-sfc-blur-ipfs-1 ipfs swarm connect /ip4/$IP_gray/tcp/4001/p2p/$peerID_gray
docker exec ipfs-sfc-gray-ipfs-1 ipfs swarm connect /ip4/$IP_blur/tcp/4001/p2p/$peerID_blur
