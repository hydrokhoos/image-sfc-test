# image-sfc-test

## デプロイ
### 1. レポジトリをクローン
```sh
git clone https://github.com/hydrokhoos/image-sfc-test.git
```

### 2. コンテナをデプロイ
```sh
cd image-sfc-test/ipfs-sfc-blur
docker-compose up -d
```
```sh
cd image-sfc-test/ipfs-sfc-gray
docker-compose up -d
```

### 3. NFDの接続
```sh
docker network create ndn_network
```
```sh
cd image-sfc-test/ipfs-sfc-blur
docker-compose exec ndn nfdc face create tcp4://ipfs-sfc-gray-ndn-1.ndn_network
docker-compose exec ndn nfdc route add / nexthop <生成されたFaceの番号>
```
```sh
cd image-sfc-test/ipfs-sfc-gray
docker-compose exec ndn nfdc face create tcp4://ipfs-sfc-gray-ndn-1.ndn_network
docker-compose exec ndn nfdc route add / nexthop <生成されたFaceの番号>
```

### 4. IPFS (Kubo) の接続
```sh
# KuboのIDを確認
docker-compose exec ipfs ipfs id -f="<id>\n"
# 接続先のKuboコンテナのIPとIDを調べて接続
docker-compose exec ipfs ipfs swarm connect /ip4/<接続先IP>/tcp/4001/p2p/<接続先ID>
```

## 使い方
### NDNでSFC
#### 1. プロデューサー起動
```sh
docker-compose exec ndn sh -c "ndnputchunks /ipfs/bafkreie7ohywtosou76tasm7j63yigtzxe7d5zqus4zu3j6oltvgtibeom < /src/bafkreie7ohywtosou76tasm7j63yigtzxe7d5zqus4zu3j6oltvgtibeom.jpg"
```
#### 2. SFC起動
```sh
cd image-sfc-test/ipfs-sfc-blur
docker-compose exec ndn python3 /src/ndnsfc.py

cd image-sfc-test/ipfs-sfc-gray
docker-compose exec ndn python3 /src/ndnsfc.py
```

#### 3. コンテンツ要求
```sh
docker-compose exec ndn sh -c "ndncatchunks -f /blur/convertGray/ipfs/bafkreie7ohywtosou76tasm7j63yigtzxe7d5zqus4zu3j6oltvgtibeom > /src/result.jpg"
```

### IPFS+NDNでSFC
#### 1. SFC起動
```sh
cd image-sfc-test/ipfs-sfc-blur
docker-compose exec ndn python3 /src/sfcg.py

cd image-sfc-test/ipfs-sfc-gray
docker-compose exec ndn python3 /src/sfcg.py
```

#### 2. コンテンツ要求
```sh
docker-compose exec ndn ndnpeek -fp -w 50000 /blur/convertGray/ipfs/bafkreie7ohywtosou76tasm7j63yigtzxe7d5zqus4zu3j6oltvgtibeom
```

## 削除
```sh
cd image-sfc-test/ipfs-sfc-blur
docker-compose down -v
```
```sh
cd image-sfc-test/ipfs-sfc-gray
docker-compose down -v
