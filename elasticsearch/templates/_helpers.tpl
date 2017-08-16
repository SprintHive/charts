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
