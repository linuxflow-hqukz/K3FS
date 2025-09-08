# K3FS
K3FS(3FS in Kubernetes)项目灵感来源于[open3fs/m3fs](https://github.com/open3fs/m3fs), 旨在于Kubernetes集群中快速部署3FS文件系统。
# 环境要求
操作系统：Ubuntu22.04  
Kubernetes集群：v1.30.5  
私有镜像仓库(可选)  
# 快速开始
```
cd chart  
helm upgrade --install 3fs ./ --namespace 3fs --create-namespace  
```
默认模式是使用dir，如果有硬盘(建议使用NVME硬盘)，可以指定StorageType: "disk"，会根据DiskPerNode: n参数对前n个硬盘(系统盘除外)进行格式化。  
如果想查看详细部署过程可以使用helm的debug参数。  
K3FS支持rdma、rdma_rxe两种网络，默认模式下使用的是rdma_rxe，如果有支持RDMA的网卡也可以将设置为NetworkType: "rdma"
```
helm upgrade --install 3fs ./ --namespace 3fs --create-namespace --debug  
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
#指定节点的硬盘：
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
