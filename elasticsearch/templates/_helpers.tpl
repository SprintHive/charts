{{/*
Add SearchGuard to plugins if it is enabled
*/}}
{{- define "elasticsearch.plugins" -}}
{{- if eq .Values.SearchGuard.Enabled true -}}
{{- printf "%s" .Values.Plugins -}}
{{- else -}}
{{- printf "%s,%s" .Values.Plugins .Values.SearchGuard.Plugin -}}
{{- end -}}
