## docker环境

### 安装wsl

+ [win10安装](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

+ [修改root用户密码](https://askubuntu.com/questions/931940/unable-to-change-the-root-password-in-windows-10-wsl)

+ 使用ssh客户端连接wsl

+ [把wsl移动到其他盘](https://stackoverflow.com/questions/38779801/move-wsl-bash-on-windows-root-filesystem-to-another-hard-drive)

  wsl默认安装在c盘，后续构建的docker image都会在c盘。把wsl移动到其他盘，可以防止c盘空间不足。
  
  使用工具lxrunoffline移动盘符。lxrunoffline list列出已安装的发行版，lxrunoffline move将发行版移动到指定目录。

### 安装Docker Desktop for Windows 

+ [DockerDesktop安装](https://docs.docker.com/docker-for-windows/install/)

+ 使用lxrunoffline移动docker的发行版到其他盘

### 主机和wsl之间拷贝文件

主机的盘符会挂载到wsl的/mnt目录下，c盘对应/mnt/c，d盘对应/mnt/d。

通过ssh客户端登录wsl，使用linux指令拷贝文件。

### wsl和容器之间拷贝文件

使用docker cp命令在容器宿主机（wsl）和容器之间拷贝文件。

由于在windows主机和wsl中都找不到docker的根目录/var/lib/docker，所以如果要拷贝docker image中的文件，需要把docker image启动成容器。


## Dockerfile

[Dockerfiles最佳实践](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/) 

1. 减少镜像构建时间。利用镜像分层的特性，越不容易变化的内容放到越底层。
2. 降低镜像大小。每条指令都是镜像的一层，合并指令减少层数；利用多阶段构建，保留必要的内容；考虑使用什么基础镜像。利用docker history检查每一层的大小。
3. 利用镜像缓存。不仅能够减少镜像构建时间，也可以减少镜像在公网分发的时间。

## 缓存Gradle项目依赖

由于项目在Docker环境中构建，所以每次构建都需要下载依赖。Dockerfile中只支持匿名卷，参考[Named Volumes in Dockerfile](https://github.com/moby/moby/issues/30647) 。

别的语言也遇到相同的问题，解决的方式是先构建依赖，在做其他的事情，通过image cache缓存依赖。参考[Can You Mount a Volume While Building Your Docker Image to Cache Dependencies](https://vsupalov.com/cache-docker-build-dependencies-without-volume-mounting/) 。

java解决问题的方式也一样。参考[Caching gradle build](https://stackoverflow.com/questions/58593661/slow-gradle-build-in-docker-caching-gradle-build) 。

Gradle官方对ephemeral container的支持，[Dealing with ephemeral builds](https://docs.gradle.org/current/userguide/dependency_resolution.html#sub:ephemeral-ci-cache) 。

## 调试DockerContainer

运行docker container后，通过docker exec -it ${container_id} bash进入容器内部，使用linux指令调试Container。

如果docker container无法启动，修改docker image的启动指令，改成一个不会报错的脚本。比如"/bin/sh -c while true; do sleep 2; date; done"。

更多调试方法参考[Ten tips for debugging Docker containers](https://medium.com/@betz.mark/ten-tips-for-debugging-docker-containers-cde4da841a1d) 。

## IDEA对Docker的支持

IDEA提供了Docker面板，可以管理image和container，将docker命令行的大部分行为可视化。比如查看container的绑定端口，挂载卷。

## 管理多台主机的Docker服务

portainer.io提供了管理多主机Docker服务的功能。被管理的客户端需要开启Docker Remote API。

[部署portainer服务端](https://documentation.portainer.io/v2.0/deploy/ceinstalldocker/) 

[客户端安装代理](https://documentation.portainer.io/v2.0/deploy/ceinstalldocker/) 

portainer支持通过git下载源码，构建镜像，运行容器。

1.构建镜像：

Images - Build a new Image

指定镜像name，指定git仓库的url。

2.push to Registry

为image打Tag：userName/repositoryName:tagName，打了标签的image，可以push到Registry。

3.运行容器

Containers - Add contaienr

指定容器name，指定远程镜像地址，映射端口。







