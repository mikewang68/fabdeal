#基于Hyperledger Fabric1.4的商品交易溯源系统
##一.系统概述与运行环境
###1.1系统概述
本系统主要使用Hyperledger Fabric构建底层区块链网络, go 编写智能合约，应用层使用gin+fabric-sdk-go，前端使用vue+element-ui。主要功能包括：管理员为客户创建商品，客户可以查看所拥有的商品信息。管理员可以对商品信息进行删除、修改操作。客户可以发起销售，所有客户均可查看销售列表，购买者购买后进行扣款操作，并等待卖家确认收款，交易完成后，更新商品持有人，在有效期期间可以随时取消交易，有效期到期后自动关闭交易；客户可以发起捐赠，指定受赠人，受赠人确认接收受赠前，双方可取消捐赠/受赠。
###1.2运行环境
| 系统开发环境 | 版本信息 |
| :-: | :-: | 
| 虚拟机 | VMware Workstation Pro 17Pro |
| Linux系统 | Ubuntu v20.04 |
| 区块链平台 | Hyperledger Fabric v1.4|
| 容器引擎 | Docker v20.10.25 |
| 容器管理服务 | Docker-composer v1.25.0 |
| 浏览器 | Firefox |
| 客户端URL工具 | cURL7.68.0 |
| 版本控制工具 | Git v2.25.1 |
| 集成开发平台 | Visual Studio Code |

---

##二.Fabric环境搭建（默认安装好虚拟机）
如未安装虚拟机请参考：http://t.csdn.cn/bKOHy
###2.1安装git
`sudo apt install git
`
###2.2安装curl
`sudo apt install curl
`
###2.3安装docker
`sudo apt install docker.io
`  
  
查看docker版本
![](2023-08-27-21-01-33.png)  
##2.4安装docker-compose
`sudo apt install docker-compose
`  
  
查看docker-compose版本
![](2023-08-27-21-05-16.png)
  
##2.5安装go
这里以安装go1.18.5为例  
  
下载go1.18.5安装包：  
`sudo wget https://golang.google.cn/dl/go1.18.5.linux-amd64.tar.gz
`  
解压go1.18.5安装包：  
`sudo tar xfz go1.18.5.linux-amd64.tar.gz -C /usr/local
`
  
设置环境变量：  
* 打开文件：`sudo vim /etc/profile
  `
* 进入编辑模式，将以下内容追加到文件末尾:  
`export GOROOT=/usr/local/go  
  `  
`export GOPATH=$HOME/gowork
`  
`export GOBIN=$GOPATH/bin
`  
`export PATH=$GOPATH:$GOBIN:$GOROOT/bin:$PATH
`  
* 使环境变量生效：`source /etc/profile
  `
* 使环境变量保持生效：  
  1、进入bashrc ：  
  `cd ~
  `  
  `sudo vim .bashrc
  `  
  2、在文件末尾加入如下命令：
  `source /etc/profile
  `  

查看go版本
![](2023-08-27-21-31-41.png)
##2.6安装node与npm
下载node安装包：  
`wget https://nodejs.org/download/release/v8.1.0/node-v8.1.0-linux-x64.tar.gz
`  
解压node压缩包：  
`sudo tar -zxvf node-v8.1.0-linux-x64.tar.gz -C /usr/local
`  
配置环境变量：  
`sudo ln -s /usr/local/node-v8.1.0-linux-x64/bin/node /usr/bin/node
`  
`sudo ln -s /usr/local/node-v8.1.0-linux-x64/bin/npm /usr/bin/npm
`  
查看node、npm版本
![](2023-08-27-21-41-29.png)
##2.7官方案例的下载
* 在~/gowork/src路径下创建目录：`mkdir -p github.com/hyperledger
  `
* 切换到文件目录：`cd github.com/hyperledger
  `
* 克隆官方案例源码：`git clone https://github.com/hyperledger/fabric-samples.git
`
* 源码版本的切换（这里以切换1.4.4为例）：`git checkout v1.4.4
  `
* 检查版本是否切换成功：`git branch
  `
  ![](2023-08-28-22-25-32.png)
* 进入fabric目录下，执行源码的编译：`make release
  `,编译好的文件位于：~/gowork/src/github.com/hyperledger/fabric/release/linux-am64/bin
* 进入fabric-ca目录下，执行源码的编译：`make fabric-ca-client
  `, 
  `make fabric-ca-server
  `，编译好的文件位于： ~/fabric-ca/bin内
* 将上述所有编译好的文件复制到 fabric-samples文件夹下的bin文件夹中（没有bin文件夹就自行创建），为后期的区块链网络的运行做准备，操作完后如下图所示：
![](2023-08-28-22-43-59.png)
* 将fabric文件夹下的sampleconfig文件夹移动到fabric-samples中，并命名为config，如下图所示：
![](2023-08-28-22-52-50.png)
* 在fabric/scripts目录下完成docker镜像的下载：`sudo ./bootstrap.sh 1.4.4 -b -s
  `
* 在fabric-samples/first-network目录下执行：  
  网络证书的生成：`./byfn.sh generate
  `  
  重启docker服务：`sudo service docker restart
  `  
  开启新会话：`newgrp - docker
  `  
  区块链网络的启动：`./byfn.sh up
  `，启动成功如下图所示：
  ![](2023-08-28-23-01-34.png)
  ![](2023-08-28-23-05-05.png)
* 如果启动失败可以尝试以下方法：  
  创建docker用户组：`sudo groupadd docker
  `  
  将当前用户加入用户组：`sudo gpasswd -a ${USER} docker
  `  
  重启docker服务：`sudo service docker restart
  `  
  开启新会话：`newgrp - docker
  `  
* 网络开启成功后，需关闭网络：`./byfn.sh down
  `，防止后续出现错误
##三.项目介绍
###3.1启动项目
1、进入项目中network目录下，输入`./stop.sh
`
命令清理环境,再执行`./start.sh`，部署区块链网络和智能合约  
2、进入项目中application目录下，先执行`./build.sh
`，再执行`./start.sh`启动前后端应用  
3、使用浏览器访问前端页面：http://127.0.0.1:8000/web  
4、区块连浏览器链接：http://127.0.0.1:8080/ ，用户名admin，密码123456
##3.2系统介绍
* 系统登录页面
  ![](2023-08-29-21-43-09.png)
* 新增商品页面
  ![](2023-08-29-21-43-49.png)
* 删除/修改商品页面
  ![](2023-08-29-21-44-19.png)
* 销售模块
  ![](2023-08-29-21-44-47.png)
* 捐赠模块
  ![](2023-08-29-21-45-24.png)
#鸣谢
本项目在实现过程中，特别鸣谢原作者对该项目的无私贡献和辛勤努力。他/她的精心设计和开发，为我们提供了一个优秀的项目基础：  
https://github.com/togettoyou/fabric-realty
https://gitee.com/real__cool/fabdeal  

我们承诺尊重原作者的努力和成果，并会努力保持项目的质量和可持续发展。
再次感谢原作者对项目所做的贡献！







