{{/* vim: set filetype=mustache: */}}
{{/*
Add SearchGuard to plugins if it is enabled
*/}}
{{- define "plugins" -}}
{{- if ne (.Values.SearchGuard.Enabled | quote) "true" -}}
{{- .Values.Plugins | quote -}}
{{- else -}}
{{- (printf "%s,%s" .Values.Plugins .Values.SearchGuard.Plugin) | quote -}}
{{- end -}}
{{- end -}}

{{/*
Init containers required to run Elasticsearch
*/}}
{{- define "init_containers" -}}
initContainers:
{{- /* https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html */}}
- name: "sysctl"
  image: "busybox"
  imagePullPolicy: "IfNotPresent"
  command: ["sysctl", "-w", "vm.max_map_count=262144"]
  securityContext:
    privileged: true
- name: copy-config
  image: {{.Values.Image}}
  command: [ "/bin/sh", "-c", "cp -LR /tmp/configmap/* /tmp/config-dir/" ]
  volumeMounts:
  - name: config-dir
    mountPath: /tmp/config-dir
  - name: config-configmap
    mountPath: /tmp/configmap
{{- end}}
