
## MinIO 分布式部署

* 注意使用 `gateway` 方式部署多个实例或多个存储相互独立无法组合成集群  
* 在 NAS 上使用分布式部署好处是可以使用更多的特性, 坏处是挺浪费空间的
* 分布式集群必须使用 `server` 方式部署, 可以 1 个 server 搭 4 个存储, 也可以多个 server
* 在 NAS 上除非需要用到多版本控制的特性, 否则不考虑使用分布式部署
* [官方文档介绍][1]
* [docker-compose.yml][3]
* [nginx.conf][4]

[1]: https://docs.min.io/docs/distributed-minio-quickstart-guide.html
[2]: https://docs.min.io/docs/deploy-minio-on-docker-compose.html
[3]: https://github.com/minio/minio/blob/master/docs/orchestration/docker-compose/docker-compose.yaml
[4]: https://github.com/minio/minio/blob/master/docs/orchestration/docker-compose/nginx.conf
