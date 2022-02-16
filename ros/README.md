---
title: ROS Settings
date: 2022-01-05T11:42:08+08:00
slug: ros-settings
---

## 基础设定

* 设置IP地址

```
/ip address
add address=192.168.1.1/24 comment="default configuration" interface=lan1 network=192.168.1.0
```

* PPPOE 拨号上网

```
/interface ethernet
set [ find default-name=ether1 ] name=lan1
set [ find default-name=ether2 ] name=wan1
/interface pppoe-client add name=pppoe interface=wan1 user=xxxx password=yyyy add-default-route=yes disabled=no
```

* 开启IP伪装共享上网(源地址为本局域网IP的IP数据包, 统一替换为路由器公网IP)

```
/ip firewall nat add chain=srcnat action=masquerade
```

* 设置DNS

```
/ip dns
set allow-remote-requests=yes servers=218.85.157.99,218.85.152.99
```

* 配置 dhcp 服务
```
/ip pool add name=dhcp_pool0 ranges=192.168.1.5-192.168.1.253
/ip dhcp-server
add name=dhcp interface=lan1 address-pool=dhcp_pool0 lease-time=10m
/ip dhcp-server network
add address=192.168.1.0/24 gateway=192.168.1.2 dns-server=218.85.157.99,218.85.152.99 netmask=24
```

## 安全设定

* 关闭不需要的服务
```
/ip service
set telnet disabled=yes
set ftp disabled=yes
set api disabled=yes
set winbox disabled=yes
set api-ssl disabled=yes
```

* 防火墙规则
```
/ip firewall filter
add action=drop chain=input dst-port=53 in-interface=pppoe protocol=udp
add action=drop chain=input dst-port=53 in-interface=pppoe protocol=tcp
add action=drop chain=input comment="Drop Invalid Connections" connection-state=invalid
add action=accept chain=input comment="Allow Established Connections" connection-state=established
add action=accept chain=input comment="Allow ICMP" protocol=icmp
add action=accept chain=input in-interface=lan1 src-address=192.168.1.0/24
add action=drop chain=input comment="Drop Everything Else"
add action=accept chain=output comment="Accept Everything"
add action=drop chain=forward comment="Drop Invalid Connections" connection-state=invalid
add action=accept chain=forward comment="Allow Established Connections" connection-state=established
add action=accept chain=forward comment="Allow Related Connections" connection-state=related
add action=jump chain=forward jump-target=tcp protocol=tcp
add action=jump chain=forward jump-target=udp protocol=udp
add action=jump chain=forward jump-target=icmp protocol=icmp
add action=drop chain=input comment="Forbid Ping" protocol=icmp src-address=!192.168.1.0/24
```

## DDNS

```
/system script
add comment=script_ddns dont-require-permissions=no name=script_ddns owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":local domain \"codiy.net\"\
    \n:local record \"www\"\
    \n:local pppoe \"pppoe\"\
    \n\
    \n:local ipaddr [/ip address get [/ip address find interface=\$pppoe] address]\
    \n:set ipaddr [:pick \$ipaddr 0 ([len \$ipaddr] -3)]\
    \n:global ddnsipv4\
    \n:if (\$ipaddr != \$ddnsipv4) do={\
    \n    :local result [/tool fetch url=\"https://xxxxxxxxx/ddns\\\?domain=\$domain&rr=\$record&ip=\$ip\
    addr\" as-value output=user];\
    \n    :if (\$result->\"status\" = \"finished\") do={\
    \n        :if (\$result->\"data\" = \"0\") do={\
    \n            :set ddnsipv4 \$ipaddr\
    \n            :log info \"alidns update ok\";\
    \n        } else={\
    \n            :log info \"alidns update error\";\
    \n        }\
    \n    }\
    \n}"
```

## 回流+端口转发

* 添加 NAT 规则, 目标地址为本机公网IP的数据包, 都直接转给下一规则 post-nat

```
/ip firewall nat
add action=jump chain=dstnat comment=dynamic_nat dst-address=100.64.71.98 jump-target=port-nat
```

* 动态设置 dst-address 的脚本

```
add dont-require-permissions=no name=script_dynamic_nat owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":global dnatold\
    \n\
    \n:global dnatnew\
    \n\
    \n:set dnatnew [/interface get [/interface find name=\"pppoe\"] running]\
    \n\
    \n:if (\$dnatnew=true) do={\
    \n\
    \n:set dnatold [/ip address get [/ip address find dynamic=yes interface=\"pppoe\"] address]\
    \n\
    \n:set dnatold [:pick \$dnatold 0 ([:len \$dnatold ] -3)]\
    \n\
    \n/ip firewall nat set [/ip firewall nat find comment=\"dynamic_nat\"] dst-address=\$dnatold\
    \n\
    \n}\
    \n\
    \n"
```

* 添加 profile 让 pppoe 拨号时候自动触发脚本

```
/ppp profile
add change-tcp-mss=yes name=pppoe-client-profile on-up="delay 3s\
    \n:execute \"script_dynamic_nat\""
/interface pppoe-client set profile=pppoe-client-profile [find name="pppoe"]
```

* 添加端口转发规则

```
/ip firewall nat
add action=dst-nat chain=port-nat comment="nas port nat" dst-port=5000 protocol=tcp to-addresses=192.168.1.3 to-ports=5000
```

## Upnp

```
/ip upnp
set allow-disable-external-interface=yes enabled=yes
/ip interfaces
add interface=pppoe type=external
add interface=lan1 type=internal
```

## VPN设定

* L2TP

```
/ppp profile
add name=l2tp-profile use-encryption=yes
/ppp secret
add local-address=10.0.0.1 name=codiy password=xxxxx profile=l2tp-profile remote-address=10.0.0.2 service=l2tp
/interface l2tp-server server
set default-profile=l2tp-profile enabled=yes use-ipsec=yes
```

## VPN IKEV2

### [certifications](https://help.mikrotik.com/docs/display/ROS/Certificates)

* 新增

```
/certificate
add name=CA digest-algorithm=sha256 key-type=rsa common-name=CA key-size=2048 subject-alt-name="" days-valid=3650 trusted=yes

add name=Server digest-algorithm=sha256 key-type=rsa common-name=Server key-size=2048 subject-alt-name=""
           days-valid=3650 trusted=yes key-usage=tls-server ca=CA

add name="Client" digest-algorithm=sha256 key-type=rsa common-name="Client" key-size=2048 subject-alt-name=""
           days-valid=3650 trusted=yes key-usage=tls-client ca=CA
```

* 签名

```
/certificate
sign CA-Template
sign Client
sign Server ca-crl-host=192.168.88.1 name=ServerCA
```

* 导出

```
/certificate
export-certificate CA-Template
export-certificate ServerCA export-passphrase=yourpassphrase
export-certificate Client export-passphrase=yourpassphrase
```

### IKEV2 Setup

```
/ip pool
add name=ikev2_pool ranges=10.0.0.1-10.0.0.6

/ip ipsec mode-config
add address-pool=ikev2_pool address-prefix-length=29 name=ikev2-cfg static-dns=192.168.1.1 system-dns=no
/ip ipsec policy group
add name=ikev2-group
/ip ipsec profile
add enc-algorithm=aes-256,aes-128 hash-algorithm=sha256 name=ikev2-profile
/ip ipsec peer
add exchange-mode=ike2 name=ikev2-peer passive=yes profile=ikev2-profile send-initial-contact=no
/ip ipsec proposal
add auth-algorithms=sha256,sha1 enc-algorithms=aes-256-cbc,aes-128-cbc lifetime=23h59m59s name=ikev2-proposal
/ip ipsec identity
add auth-method=digital-signature certificate=Server generate-policy=port-strict match-by=certificate mode-config=\
    ikev2-cfg my-id=fqdn:Server peer=ikev2-peer policy-template-group=ikev2-group remote-certificate=Client
/ip ipsec policy
add dst-address=10.0.0.0/29 group=ikev2-group proposal=ikev2-proposal src-address=0.0.0.0/0 template=yes
```

## References

* [RouterOS wiki](https://wiki.mikrotik.com/wiki/Manual:TOC)
* [RouterOS docs](https://help.mikrotik.com/docs/display/ROS/RouterOS)
