{{/*
Add SearchGuard to plugins if it is enabled
*/}}
{{- define "plugins" -}}
{{- if ne (.Values.SearchGuard.Enabled | quote) "true" -}}
{{- .Values.Plugins -}}
{{- else -}}
{{- printf "%s,%s" .Values.Plugins .Values.SearchGuard.Plugin -}}
{{- end -}}
{{- end -}}
