{{- define "RdmaConfig.hook.annotations" -}} 
"helm.sh/resource-priority": "1"
{{- end -}} 

{{- define "Monitor.hook.annotations" -}} 
"helm.sh/resource-priority": "10"
{{- end -}} 

{{- define "InitCluster.hook.annotations" -}}
"helm.sh/resource-priority": "20"
{{- end -}}

{{- define "Mgmtd.hook.annotations" -}}
"helm.sh/resource-priority": "30"
{{- end -}}

{{- define "Meta.hook.annotations" -}}
"helm.sh/resource-priority": "40"
{{- end -}}

{{- define "Storage.hook.annotations" -}}
"helm.sh/resource-priority": "50"
{{- end -}}

{{- define "CreateUser.hook.annotations" -}}
"helm.sh/hook": post-install
"helm.sh/hook-weight": "10"
{{- end -}}

{{- define "CreateTargets.hook.annotations" -}}
"helm.sh/hook": post-install
"helm.sh/hook-weight": "20"
{{- end -}}

{{- define "CreateChains.hook.annotations" -}}
"helm.sh/hook": post-install
"helm.sh/hook-weight": "30"
{{- end -}}

{{- define "CreateChainTable.hook.annotations" -}}
"helm.sh/hook": post-install
"helm.sh/hook-weight": "40"
{{- end -}}

{{- define "AdminCli.hook.annotations" -}}
"helm.sh/hook": post-install
"helm.sh/hook-weight": "50"
{{- end -}}

{{- define "FuseClient.hook.annotations" -}}
"helm.sh/hook": post-install
"helm.sh/hook-weight": "60"
{{- end -}}

