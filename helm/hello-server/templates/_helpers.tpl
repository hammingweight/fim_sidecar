{{/*
The service name.
*/}}
{{- define "hello-server.servicename" -}}
{{- if .Values.serviceName }}
{{- .Values.serviceName }}
{{- else }}
{{- printf "%s-service" .Release.Name }}
{{- end }}
{{- end }}

{{/*
The pod (app) name.
*/}}
{{- define "hello-server.podname" -}}
{{- if .Values.podName }}
{{- .Values.podName }}
{{- else }}
{{- printf "%s-server" .Release.Name }}
{{- end }}
{{- end }}

{{/*
The selector labels.
*/}}
{{- define "hello-server.selectorLabels" -}}
app: {{ include "hello-server.podname" . }}
{{- end }}
