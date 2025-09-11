# K3FS
K3FS(3FS in Kubernetes)项目灵感来源于[open3fs/m3fs](https://github.com/open3fs/m3fs), 旨在于Kubernetes集群中快速部署3FS文件系统。
# 环境要求
操作系统：Ubuntu22.04  
部署好Clickhouse(22.8.5.29)和FoundationDB(7.3.63)   
私有镜像仓库(可选)  
Kubernetes(v1.30.5)集群，需要给所有运行3fs集群的节点打上标签
```
# 示例
kubectl label nodes  worker01 3fs-cluster=3fs01

kubectl  get node --show-labels 
NAME       STATUS   ROLES           AGE   VERSION   LABELS
master01   Ready    control-plane   19d   v1.30.5   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=master01,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node.kubernetes.io/exclude-from-external-load-balancers=
worker01   Ready    <none>          19d   v1.30.5   3fs-cluster=3fs01,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=worker01,kubernetes.io/os=linux
worker02   Ready    <none>          19d   v1.30.5   3fs-cluster=3fs02,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=worker02,kubernetes.io/os=linux
worker03   Ready    <none>          19d   v1.30.5   3fs-cluster=3fs03,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=worker03,kubernetes.io/os=linux
```
需要节点支持avx512，基础镜像来自于open3fs，如果不支持avx512，请使用avx2基础镜像进行构建。
```
root@master01:~# lscpu | grep avx512
Flags:       fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon nopl xtopology tsc_reliable nonstop_tsc cpuid tsc_known_freq pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch ssbd ibrs ibpb stibp ibrs_enhanced fsgsbase tsc_adjust bmi1 avx2 smep bmi2 invpcid avx512f avx512dq rdseed adx smap clflushopt clwb avx512cd avx512bw avx512vl xsaveopt xsavec xgetbv1 xsaves arat pku ospke avx512_vnni md_clear flush_l1d arch_capabilities
```
# 快速开始
构建镜像及推送，根据实际环境修改values.yaml的镜像名称以及Clickhouse参数、fdb参数和3fs集群参数。
```
docker build -t  192.168.2.199:28080/k3fs/k3fs:v0.1.0 .
docker push  192.168.2.199:28080/k3fs/k3fs:v0.1.0 
```
开始部署
```
cd chart/  
helm upgrade --install 3fs ./ --namespace k3fs --create-namespace  
```
等待部署完成
```
kubectl  get pod -n k3fs

NAME                         READY   STATUS      RESTARTS   AGE
admin-cli-6d955d4455-5nnpj   1/1     Running     0          118s
fuse-client-1                1/1     Running     0          118s
fuse-client-2                1/1     Running     0          118s
fuse-client-3                1/1     Running     0          118s
gen-chaintable-job-lb9r8     0/1     Completed   0          4m23s
init-cluster-job-p5887       0/1     Completed   0          5m25s
meta-101                     1/1     Running     0          5m25s
meta-102                     1/1     Running     0          5m25s
meta-103                     1/1     Running     0          5m25s
mgmtd-1                      1/1     Running     0          5m25s
mgmtd-2                      1/1     Running     0          5m24s
mgmtd-3                      1/1     Running     0          5m24s
monitor-7b44d645dc-vlqbz     1/1     Running     0          5m25s
rdma-config-worker01-tmsvk   0/1     Completed   0          5m25s
rdma-config-worker02-s9gn2   0/1     Completed   0          5m25s
rdma-config-worker03-rb5ml   0/1     Completed   0          5m25s
storage-10001                1/1     Running     0          5m25s
storage-10002                1/1     Running     0          5m24s
storage-10003                1/1     Running     0          5m24s
user-add-job-c4g4k           0/1     Completed   0          5m24s
```
K3FS支持rdma、rxe两种网络，默认模式下使用的是rxe，如果有支持RDMA的网卡(建议使用迈洛思网卡)也可以将设置为NetworkType: "rdma"或者通过--set RdmaConfig.NetworkType=rdma进行传入；默认模式是使用dir，如果有硬盘(建议使用NVME硬盘)，可以指定StorageType: "disk"，或者通过--set Storage.StorageType=disk进行传入，会根据DiskPerNode: n参数对前n个硬盘(系统盘除外)进行格式化。  
```
# 示例
helm upgrade --install 3fs ./ --set RdmaConfig.NetworkType=rdma --set RdmaConfig.NetworkCard=ens160 --set Storage.StorageType=disk --namespace k3fs --create-namespace  --debug
```

如果想查看详细部署过程可以使用helm的debug参数。  
```
helm upgrade --install 3fs ./ --namespace 3fs --create-namespace --debug  
```
首次安装如果拉取镜像时间较长可能会导致部署失败，helm默认部署时间是5分钟，可以设置--timeout参数以增加部署时间。
```
helm upgrade --install 3fs ./ --namespace 3fs --create-namespace --debug --timeout 10m
```
# 查看集群
查看服务端节点  
```
kubectl exec -n k3fs deployments/admin-cli  -- bash -c "/opt/3fs/bin/admin_cli -cfg /opt/3fs/etc/admin_cli.toml \"list-nodes\"" 

Id     Type     Status               Hostname  Pid  Tags  LastHeartbeatTime    ConfigVersion  ReleaseVersion
2      MGMTD    PRIMARY_MGMTD        worker03  17   []    N/A                  1(UPTODATE)    250228-dev-1-999999-ee9a5cee
1      MGMTD    HEARTBEAT_CONNECTED  worker02  17   []    2025-09-09 16:04:41  1(UPTODATE)    250228-dev-1-999999-ee9a5cee
3      MGMTD    HEARTBEAT_CONNECTED  worker01  17   []    2025-09-09 16:04:42  1(UPTODATE)    250228-dev-1-999999-ee9a5cee
101    META     HEARTBEAT_CONNECTED  worker01  52   []    2025-09-09 16:04:42  3(UPTODATE)    250228-dev-1-999999-ee9a5cee
102    META     HEARTBEAT_CONNECTED  worker03  58   []    2025-09-09 16:04:42  3(UPTODATE)    250228-dev-1-999999-ee9a5cee
103    META     HEARTBEAT_CONNECTED  worker02  52   []    2025-09-09 16:04:43  3(UPTODATE)    250228-dev-1-999999-ee9a5cee
10001  STORAGE  HEARTBEAT_CONNECTED  worker01  73   []    2025-09-09 16:04:50  3(UPTODATE)    250228-dev-1-999999-ee9a5cee
10002  STORAGE  HEARTBEAT_CONNECTED  worker03  79   []    2025-09-09 16:04:49  3(UPTODATE)    250228-dev-1-999999-ee9a5cee
10003  STORAGE  HEARTBEAT_CONNECTED  worker02  73   []    2025-09-09 16:04:50  3(UPTODATE)    250228-dev-1-999999-ee9a5cee
```
查看客户端节点  
```
kubectl exec -n k3fs deployments/admin-cli  -- bash -c "/opt/3fs/bin/admin_cli -cfg /opt/3fs/etc/admin_cli.toml \"list-clients\""

ClientId                              ClientStart          SessionStart         LastExtend           ConfigVersion  Hostname  Description     Tags  ReleaseVersion
b31b277e-b572-4abd-971d-57454b7b56f8  2025-09-09 15:55:53  2025-09-09 15:55:53  2025-09-09 16:05:13  3              worker01  fuse: worker01  []    250228-dev-1-999999-ee9a5cee
5621829e-cdc1-4228-a00b-a8843cb204f8  2025-09-09 15:55:54  2025-09-09 15:55:54  2025-09-09 16:05:14  3              worker02  fuse: worker02  []    250228-dev-1-999999-ee9a5cee
622ef68e-12dc-4e5c-806f-feb483749eec  2025-09-09 15:55:54  2025-09-09 15:55:54  2025-09-09 16:05:14  3              worker03  fuse: worker03  []    250228-dev-1-999999-ee9a5cee
```
客户端查看挂载
```
kubectl exec -n k3fs fuse-client-1  -- bash -c "df -h"

Filesystem                 Size  Used Avail Use% Mounted on
overlay                    249G   19G  217G   9% /
tmpfs                       64M     0   64M   0% /dev
/dev/mapper/vgubuntu-root  249G   19G  217G   9% /etc/hosts
shm                         64M   12K   64M   1% /dev/shm
tmpfs                       16G   12K   16G   1% /run/secrets/kubernetes.io/serviceaccount
hf3fs.k3fs                 768G  5.6G  763G   1% /mnt/3fs
```
# 自定义模式
```
helm upgrade --install 3fs ./ -f custom-values.yaml --namespace 3fs --create-namespace
``` 
在使用自定义模式部署之前，需要先对custom-values.yaml文件进行修改  
```
  replicas: 1    # 建议为1，会根据NodeAllocation参数进行循环生成多个StatefulSet，而默认模式下只会生成一个多副本的StatefulSet。  
  DeployMode: "custom"    # 指定部署模式为自定义模式  
  ClearDisk: "true"    # 硬盘存在分区或者使用硬盘分区时，会强制重新格式化分区再进行挂载，false则不会重新格式化，而是直接挂载。  
  DiskIdType: "partuuid"  # id、uuid、partuuid
  # id : ls -l /dev/disk/by-id | grep nvme-eui  
  # uuid : ls -l /dev/disk/by-uuid  
  # partuuid : ls -l /dev/disk/by-partuuid
#指定节点上的硬盘：
  NodeAllocation:    # id
    - storage: "storage-10001"
      host: "3fs01"
      disk: '["38736838bf365841000c296c8b0c1f80","938d48bfb924ef4a000c296ca5a0f04c"]'
    - storage: "storage-10002"
      host: "3fs02"
      disk: '["340a1a961286bcd7000c29627b9cd61c","c151e88fed675ffd000c296d2ffff650"]'
    - storage: "storage-10003"
      host: "3fs03"
      disk: '["02955f4c3ede13c4000c296327ed0c06","ca737554a3f24d7f000c29647ad06276"]'
#指定节点上的带分区的硬盘
  NodeAllocation:    # uuid
    - storage: "storage-10001"
      host: "3fs01"
      disk: '["f981f28d-927f-4dd9-9322-576600f195e4","1b13e603-6fe2-4039-96a2-bf5bec2cfe58"]'
    - storage: "storage-10002"
      host: "3fs02"
      disk: '["e6ca2173-8270-43d1-8c4a-8f7960694482","7f48ff46-d520-419e-8319-0fb52d123474"]'
    - storage: "storage-10003"
      host: "3fs03"
      disk: '["dc027ea3-99fd-48f8-a43a-ae204e36b7c1","1d799963-d08a-4e1d-8ad5-ebb85baf10f4"]'
#指定节点上的硬盘分区
  NodeAllocation:    # partuuid
    - storage: "storage-10001"
      host: "3fs01"
      disk: '["7d076cc9-7904-4d5e-88ff-941923215269","f24dde74-a383-4fcf-9ae9-6ff494458f27"]'
    - storage: "storage-10002"
      host: "3fs02"
      disk: '["acfe7e52-9f32-4c8c-b21a-b777b8e4725e","fff74cca-9175-48d3-a49e-4aadf947c65d"]'
    - storage: "storage-10003"
      host: "3fs03"
      disk: '["98908dce-e140-4d75-85b3-33511d253b9a","1cadd45b-8e2a-4656-9b3a-d1302ecf0141"]'
#同样也可以在一个节点上部署多个Storage服务
  NodeAllocation:    # partuuid
    - storage: "storage-10001"
      host: "3fs01"
      disk: '["7d076cc9-7904-4d5e-88ff-941923215269"]'
    - storage: "storage-10002"
      host: "3fs02"
      disk: '["acfe7e52-9f32-4c8c-b21a-b777b8e4725e"]'
    - storage: "storage-10003"
      host: "3fs03"
      disk: '["98908dce-e140-4d75-85b3-33511d253b9a"]'
    - storage: "storage-10004"
      host: "3fs01"
      disk: '["f24dde74-a383-4fcf-9ae9-6ff494458f27"]'
    - storage: "storage-10005"
      host: "3fs02"
      disk: '["fff74cca-9175-48d3-a49e-4aadf947c65d"]'
    - storage: "storage-10006"
      host: "3fs03"
      disk: '["1cadd45b-8e2a-4656-9b3a-d1302ecf0141"]'
```
# 卸载
```
helm uninstall -n k3fs 3fs
```
同时需要清空fdb数据库，使用fdbcli命令连接到fdb数据库  
```
writemode on
clearrange "" \xFF
getrange "" \xFF
```
