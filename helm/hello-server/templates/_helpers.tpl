{{/*
Generate a name for the Service.
*/}}
{{- define "hello-server.servicename" -}}
{{- if .Values.serviceName }}
{{- .Values.serviceName }}
{{- else }}
{{- printf "%s-service" .Release.Name }}
{{- end }}
{{- end }}

{{/*
Generate a name for the Pod.
*/}}
{{- define "hello-server.podname" -}}
{{- if .Values.podName }}
{{- .Values.podName }}
{{- else }}
{{- printf "%s-server" .Release.Name }}
{{- end }}
{{- end }}
