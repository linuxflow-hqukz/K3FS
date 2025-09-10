{{- define "RdmaConfig.volumeMounts" -}}
- name: rdma-config
  mountPath: /opt/3fs/shell/rdma-config.sh
  subPath: rdma-config.sh
- name: lib-modules
  mountPath: /lib/modules 
{{- end -}}

{{- define "RdmaConfig.volumes" -}}
- name: rdma-config
  configMap:
    name: rdma-config
- name: lib-modules
  hostPath:
    path: /lib/modules
{{- end -}}

{{- define "3fs-shell.volumeMounts" -}}
- name: start
  mountPath: /opt/3fs/shell/start.sh
  subPath: start.sh
- name: disktools
  mountPath: /opt/3fs/shell/disktools.sh
  subPath: disktools.sh
- name: check
  mountPath: /opt/3fs/shell/check.sh
  subPath: check.sh
- name: kube-patch
  mountPath: /opt/3fs/shell/kube-patch.sh
  subPath: kube-patch.sh
{{- end -}}

{{- define "3fs-shell.volumes" -}}
- name: start
  configMap:
    name: start
- name: disktools
  configMap:
    name: disktools
- name: check
  configMap:
    name: check
- name: kube-patch
  configMap:
    name: kube-patch
{{- end -}}


{{- define "AdminCli.volumeMounts" -}}
- name: admin-cli
  mountPath: /tmp/admin_cli.toml
  subPath: admin_cli.toml
- name: mgmtd-main
  mountPath: /tmp/mgmtd_main.toml
  subPath: mgmtd_main.toml
{{- end -}}

{{- define "AdminCli.volumes" -}}
- name: admin-cli
  configMap:
    name: admin-cli
- name: mgmtd-main
  configMap:
    name: mgmtd
    items:
    - key: mgmtd_main.toml
      path: mgmtd_main.toml
{{- end -}}


{{- define "Shared.volumeMounts" -}} 
- name: shared-volume
  mountPath: /shared-data
{{- end -}}

{{- define "Shared.volumes" -}} 
- name: shared-volume
  emptyDir: {}
{{- end -}}



