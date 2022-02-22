# Syncthing

## 指定 Discovery server

* Discovery server device ID 会在启动日志中透出, 如下

```
stdiscosrv v1.19.1-rc.1.dev.5.g013c757a "Fermium Flea" (go1.17.7 linux-amd64) docker@syncthing.net 2022-02-21 13:57:21 UTC [noupgrade, purego]
Failed to load keypair. Generating one, this might take a while...
Server device ID is GWBBCVJ-YQYBLO5-5T3QAPB-L2MUJCR-ZSKUUSU-7ZKBYLZ-RNXASTJ-DFS4HAC
```

* 对于自签的证书, Syncthing GUI 指定 Discovery server 时必须明确指定设备ID

```
default, https://127.0.0.1:8443/?id=GWBBCVJ-YQYBLO5-5T3QAPB-L2MUJCR-ZSKUUSU-7ZKBYLZ-RNXASTJ-DFS4HAC
```
保留 **`default`** 是为了接入一些网络共享库, 不需要可以去掉

## 指定 Relay Server

* Relay server 连接地址也会在启动日志中透出, 如下

```
2022/02/22 06:10:06 main.go:140: strelaysrv v1.19.1-rc.1.dev.5.g013c757a "Fermium Flea" (go1.17.7 linux-amd64) docker@syncthing.net 2022-02-21 13:57:21 UTC [noupgrade]
2022/02/22 06:10:06 main.go:146: Connection limit 52428
2022/02/22 06:10:06 main.go:159: Failed to load keypair. Generating one, this might take a while...
2022/02/22 06:10:06 main.go:239: URI: relay://0.0.0.0:22067/?id=QDED7QW-LQNYZF2-DG45XBP-XUUULTJ-CMIX2PM-MQSRHJW-VBJPUK5-WN6BLQ7&pingInterval=1m0s&networkTimeout=2m0s&sessionLimitBps=0&globalLimitBps=0&statusAddr=:22070&providedBy=
```

* 在 Syncthing GUI 的 【设置】->【连接】中指定[协议监听地址]

```
default, relay://0.0.0.0:22067/?id=QDED7QW-LQNYZF2-DG45XBP-XUUULTJ-CMIX2PM-MQSRHJW-VBJPUK5-WN6BLQ7&pingInterval=1m0s&networkTimeout=2m0s&sessionLimitBps=0&globalLimitBps=0&statusAddr=:22070&providedBy=
```

## 设定端口转发使得外网可用

* (required)路由器转发发现服务器 **`8443`** 端口
* (required)路由器转发中继服务器 **`22067`** 端口
