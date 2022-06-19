{{/*
The service name.
*/}}
{{- define "hello-server.serviceName" -}}
{{- if .Values.serviceName }}
{{- .Values.serviceName }}
{{- else }}
{{- printf "%s-service" .Release.Name }}
{{- end }}
{{- end }}

{{/*
The pod (app) name.
*/}}
{{- define "hello-server.podName" -}}
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
app.kubernetes.io/name: {{ include "hello-server.podName" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
{{- end }}
