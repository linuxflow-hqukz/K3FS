{{- define "Monitor.affinity" -}} 
affinity: 
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:  
      nodeSelectorTerms:
      - matchExpressions:
        - key: {{ $.Values.Common.NodeLabel }}
          operator: Exists
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: {{ $.Values.Common.PodLabel }}
          operator: In
          values:
          - monitor
      topologyKey: "kubernetes.io/hostname"
{{- end -}}

{{- define "Mgmtd.affinity" -}} 
affinity: 
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:  
      nodeSelectorTerms:
      - matchExpressions:
        - key: {{ $.Values.Common.NodeLabel }}
          operator: Exists
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: {{ $.Values.Common.PodLabel }}
          operator: In
          values:
          - mgmtd
      topologyKey: "kubernetes.io/hostname"
{{- end -}}

{{- define "Meta.affinity" -}} 
affinity: 
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:  
      nodeSelectorTerms:
      - matchExpressions:
        - key: {{ $.Values.Common.NodeLabel }}
          operator: Exists
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: {{ $.Values.Common.PodLabel }}
          operator: In
          values:
          - meta
      topologyKey: "kubernetes.io/hostname"
{{- end -}}

{{- define "Storage.affinity" -}} 
affinity: 
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:  
      nodeSelectorTerms:
      - matchExpressions:
        - key: {{ $.Values.Common.NodeLabel }}
          operator: Exists
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: {{ $.Values.Common.PodLabel }}
          operator: In
          values:
          - storage
      topologyKey: "kubernetes.io/hostname"
{{- end -}}

{{- define "FuseClient.affinity" -}} 
affinity: 
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:  
      nodeSelectorTerms:
      - matchExpressions:
        - key: {{ $.Values.Common.NodeLabel }}
          operator: Exists
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: {{ $.Values.Common.PodLabel }}
          operator: In
          values:
          - fuse-client
      topologyKey: "kubernetes.io/hostname"
{{- end -}}

{{- define "AdminCli.affinity" -}} 
affinity: 
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:  
      nodeSelectorTerms:
      - matchExpressions:
        - key: {{ $.Values.Common.NodeLabel }}
          operator: Exists
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: {{ $.Values.Common.PodLabel }}
          operator: In
          values:
          - admin-cli
      topologyKey: "kubernetes.io/hostname"
{{- end -}}