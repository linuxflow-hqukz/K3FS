FROM open3fs/3fs:20250410
RUN apt update
RUN apt install kmod parted jq vim iputils-ping telnet net-tools xfsprogs  nvme-cli -y
