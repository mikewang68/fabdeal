#!/bin/bash

export PATH=${PWD}/hyperledger-fabric-linux-amd64-1.4.12/bin:$PATH
echo "1.清理环境"
./stop.sh

echo "2.生成证书和秘钥"
cryptogen generate --config=./crypto-config.yaml

echo "3.创建通道创世区块"
# configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./config/genesis.block -channelID carchannel
configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./config/genesis.block

echo "4.创建carchannel配置文件"
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./config/carchannel.tx -channelID carchannel

echo "5.为 Tesla 定义锚节点"
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./config/TelsaAnchor.tx -channelID carchannel -asOrg Tesla

echo "6.为 Benz 定义锚节点"
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./config/BenzAnchor.tx -channelID carchannel -asOrg Benz

echo "启动区块链网络"
docker-compose up -d
echo "正在等待节点的启动完成，等待10秒"
sleep 10

TeslaPeer0Cli="CORE_PEER_ADDRESS=peer0.tesla.com:7051 CORE_PEER_LOCALMSPID=TeslaMSP CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/tesla.com/users/Admin@tesla.com/msp"
TeslaPeer1Cli="CORE_PEER_ADDRESS=peer1.tesla.com:7051 CORE_PEER_LOCALMSPID=TeslaMSP CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/tesla.com/users/Admin@tesla.com/msp"
BenzPeer0Cli="CORE_PEER_ADDRESS=peer0.benz.com:7051 CORE_PEER_LOCALMSPID=BenzMSP CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/benz.com/users/Admin@benz.com/msp"
BenzPeer1Cli="CORE_PEER_ADDRESS=peer1.benz.com:7051 CORE_PEER_LOCALMSPID=BenzMSP CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/benz.com/users/Admin@benz.com/msp"

echo "7.创建通道"
docker exec cli bash -c "$TeslaPeer0Cli peer channel create -o orderer.carunion.com:7050 -c carchannel -f /etc/hyperledger/config/carchannel.tx"

echo "8.将所有节点加入通道"
docker exec cli bash -c "$TeslaPeer0Cli peer channel join -b carchannel.block"
docker exec cli bash -c "$TeslaPeer1Cli peer channel join -b carchannel.block"
docker exec cli bash -c "$BenzPeer0Cli peer channel join -b carchannel.block"
docker exec cli bash -c "$BenzPeer1Cli peer channel join -b carchannel.block"

echo "9.更新锚节点"
docker exec cli bash -c "$TeslaPeer0Cli peer channel update -o orderer.carunion.com:7050 -c carchannel -f /etc/hyperledger/config/TeslaAnchor.tx"
docker exec cli bash -c "$BenzPeer0Cli peer channel update -o orderer.carunion.com:7050 -c carchannel -f /etc/hyperledger/config/BenzAnchor.tx"

# -n 链码名，可以自己随便设置
# -v 版本号
# -p 链码目录，在 /opt/gopath/src/ 目录下
echo "10.安装链码"
docker exec cli bash -c "$TeslaPeer0Cli peer chaincode install -n fabric-realty -v 1.0.0 -l golang -p chaincode"
docker exec cli bash -c "$BenzPeer0Cli peer chaincode install -n fabric-realty -v 1.0.0 -l golang -p chaincode"

# 只需要其中一个节点实例化
# -n 对应上一步安装链码的名字
# -v 版本号
# -C 是通道，在fabric的世界，一个通道就是一条不同的链
# -c 为传参，传入init参数
echo "十一、实例化链码"
docker exec cli bash -c "$TeslaPeer0Cli peer chaincode instantiate -o orderer.carunion.com:7050 -C carchannel -n fabric-realty -l golang -v 1.0.0 -c '{\"Args\":[\"init\"]}' -P \"AND ('TeslaMSP.member','benzMSP.member')\""

echo "正在等待链码实例化完成，等待5秒"
sleep 5

# 进行链码交互，验证链码是否正确安装及区块链网络能否正常工作
echo "十二、验证链码"
docker exec cli bash -c "$TeslaPeer0Cli peer chaincode invoke -C carchannel -n fabric-realty -c '{\"Args\":[\"hello\"]}'"
docker exec cli bash -c "$BenzPeer0Cli peer chaincode invoke -C carchannel -n fabric-realty -c '{\"Args\":[\"hello\"]}'"