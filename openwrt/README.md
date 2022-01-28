
## 编译 OpenWrt

如何编译自己的 OpenWrt 固件详见[build-openwrt](https://github.com/codiy1992/build-openwrt)

## 在 ESXi 上安装 OpenWrt

* On MacOS, [利用 `qemu` 将编译好的 OpenWrt 固件转化为 vmdk](https://openwrt.org/docs/guide-user/virtualization/vmware)

```
brew install qemu
gzip -qd openwrt-x86-64-generic-ext4-combined.img.gz
qemu-img convert -f raw -O vmdk openwrt-x86-64-generic-ext4-combined.img openwrt-x86-64-generic-ext4-combined.vmdk
```

* On ESXi, 将 qemu 转换的 vmdk 再次转化为 ESXi 能正确识别的 vmdk 文件

```shell
cd ~/vmfs/volumes/datastore1
vmkfstools -i openwrt-x86-64-generic-ext4-combined.vmdk openwrt-2022.01.26.vmdk
```

* On ESXi Web Console, 新建虚拟机,删除默认硬盘,添加 `openwrt-2022.01.26.vmdk` 硬盘

## 扩容硬盘

因为是装在 ESXi 上, 在 ESXi 上更改硬盘大小后, 回到 OpenWrt 进行分区和挂载，如下

* `fdisk -l` 查看磁盘情况
* 使用 `cfdisk` 命令将剩余的 `free` 状态的磁盘空间进行分区, 输入分区大小, 然后`[Write]`,`[Quit]` 即可
* 使用 `mkfs.ext4 /dev/sda3` 将新的分区格式化为 `ext4` 格式
* 使用 `mount /dev/sda3 PATH_TO_MOUNT` 挂载分区到特定路径

## 将 docker graph driver 修改到具有较大空间的分区, 默认位置为 `/var/lib/docker`

```shell
echo -e '{
	"log-driver": "json-file",
	"log-opts": {
		"max-size": "10m",
		"max-file":  "1"
	},
    "graph": "/root/docker"
}' > /etc/docker/daemon.json
/etc/init.d/dockerd restart
```

## 安装 shsm

* `sftp` 将密钥文件传至 `/root/.gnupg/shsm.sec.key`
* 安装并初始化 shsm, 详见本项目 `[README.md](/README.md)`

## 挂载 iscsi 硬盘

* 配置 iscsid, 编辑 `/etc/iscsi/iscsid.conf`

* 发现 iscsi 节点

```
iscsiadm --mode discovery -t sendtargets --portal 192.168.1.3
```

* 重启 iscsid 服务, `/etc/init.d/open-iscsi restart`, 即可建立连接

* (Optional)连接到 iscsi 节点

```
iscsiadm --mode node --targetname \
iqn.2004-04.com.qnap:ts-453dmini:iscsi.openwrt.5904bc \
--portal 192.168.1.3 --login
```

* `fdisk -l` 查看硬盘
