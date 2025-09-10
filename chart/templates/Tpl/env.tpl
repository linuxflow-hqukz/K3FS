{{- define "Common.env" -}} 
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: NODE_HOSTNAME 
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName 
{{- end -}}

{{- define "Common.envFrom" -}} 
- configMapRef:
    name: {{ $.Values.Common.ConfigMapName | default "cluster-config" }}
{{- end -}}



