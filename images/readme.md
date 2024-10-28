## 镜像下载
镜像下载来自docker hub， 由于dongcker hub被墙。 在windows上使用docker destop 翻墙pull后，使用images tool 工具（安装dixtdf/image-tools:1.0.2镜像）导出

## 镜像导入
导出的镜像（*.tar）文件，上传到docker所在机器，使用 docker load -i *.tar命令导入
注： 不能使用docker import 导入，import导入时无法使用。

## 运行
参照本目录下 .sh文件，进行用于
注：arm64平台的镜像，需要下载并运行multiarch/qemu-user-static:register镜像，才可以运行。参考本目录下的.sh文件