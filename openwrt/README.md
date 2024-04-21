
## 编译 OpenWrt

如何编译自己的 OpenWrt 固件详见[build-openwrt](https://github.com/codiy1992/build-openwrt)

## 在 ESXi 上安装 OpenWrt

* On MacOS, 利用 `qemu` 将编译好的 OpenWrt 固件转化为 vmdk

[参考文档](https://openwrt.org/docs/guide-user/virtualization/vmware)

```
brew install qemu
gzip -qd openwrt-x86-64-generic-ext4-combined.img.gz
qemu-img convert -f raw -O vmdk openwrt-x86-64-generic-ext4-combined-efi.img \ 
  openwrt-x86-64-generic-ext4-combined-efi.vmdk
```
> 转换后的 `vmdk` 可供 `Vmware Workstation` 直接使用, 要在 `Vmware vSphere` (即`ESXi`) 上使用还需使  
> 用 `vmkfstools` 再做一次转换

* On ESXi, 将 qemu 转换的 vmdk 再次转化为 ESXi 能正确识别的 vmdk 文件

```shell
cd ~/vmfs/volumes/datastore1
vmkfstools -i openwrt-x86-64-generic-ext4-combined-efi.vmdk openwrt-2022.01.26.vmdk
```

* On ESXi Web Console, 新建虚拟机

    * [虚拟机选项] > [客户机操作系统版本] > 选"其他 3.x Linux(64bit)"
    * [虚拟硬件] > [网络适配器] > [适配器类型] > 选"VMNEXT 3"
    * 添加直通的PCI网卡, 并且内存选项需设置预留所有内存
    * 删除默认硬盘,添加 vmdk 硬盘

## 配置网关

### 在 web 界面操作

* 配合 ROS使用, 用作网关的 openwrt
* 直接在 web 界面操作即可
* 直通网卡和 ESXi 虚拟网卡都挂到 br-lan 底下
* 关闭 br-lan 网口的 DHCP 服务(DHCP 已由 ROS 提供的情况下)
* 设定网关为 ROS 地址
* 设定 DNS 地址

### 在命令行终端操作

* `vim /etc/config/network`

```
config interface 'lan'
        option type 'bridge'
        option proto 'static'
        option ipaddr '192.168.1.2'
        option netmask '255.255.255.0'
        option ip6assign '60'
        option _orig_ifname 'eth0'
        option _orig_bridge 'true'
        option ifname 'eth0 eth1'
        option gateway '192.168.1.1'
        option dns '218.85.157.99 218.85.152.99'
```

* `/etc/init.d/network restart`

* `passwd` 设置密码

* `fdisk -l` 查看硬盘

## 硬盘分区与挂载

* `fdisk -l` 查看磁盘情况
* 使用 `cfdisk /dev/sda` 将 `free` 状态的磁盘空间进行分区
* 使用 `mkfs.ext4 /dev/sda3` 将新的分区格式化为 `ext4` 格式
* 使用 `mount /dev/sda3 PATH_TO_MOUNT` 挂载分区到特定路径

设置自动挂载
```
opkg update
opkg install block mount
vim /etc/config/fstab
```
写入以下内容
```
config mount
    option target   '/root'
    option device   '/dev/sda3'
    option fstype   'ext4'
    option options  'rw,sync'
    option enabled  '1'
    option enabled_fsck '0'
```
设置开机启动，并重启系统后生效
```
/etc/init.d/fstab enable
/etc/init.d/fstab start
reboot
```

## 将 docker **data-root** 修改到具有较大空间的分区, 默认位置为 `/var/lib/docker`

> **在 openwrt 上请直接修改 **`/etc/config/dockerd`**, 否则修改 **`/etc/docker/daemon.json`**

```shell
echo -e '{
    "data-root": "/root/docker",
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file":  "1"
    },
    "log-level": "warn", 
    "iptables": true
}' > /etc/docker/daemon.json
/etc/init.d/dockerd restart
```
```
/etc/init.d/dockerd enable 
/etc/init.d/dockerd start
```
## 安装 shsm

* `sftp` 将密钥文件传至 `/root/.gnupg/shsm.sec.key`
* 安装并初始化 shsm, 详见本项目 `[README.md](/README.md)`


## 挂载 iscsi 硬盘, 不稳定，弃用

* 配置 iscsid, 编辑 `/etc/iscsi/iscsid.conf`

* 启动服务

```
/etc/init.d/open-iscsi enable
/etc/init.d/open-iscsi start
```

* 发现 iscsi 节点

```
iscsiadm --mode discovery -t sendtargets --portal 192.168.1.3
```

* 连接到 iscsi 节点

```
iscsiadm --mode node --targetname \
iqn.2004-04.com.qnap:ts-453dmini:iscsi.openwrt.5904bc \
--portal 192.168.1.3 --login
```

