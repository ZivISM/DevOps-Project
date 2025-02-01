{{/*
Common labels
*/}}
{{- define "habitspace.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: habitspace
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "habitspace.selectorLabels" -}}
app.kubernetes.io/name: habitspace
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }} 