{{- define "postiz.labels" -}}
helm.sh/chart: {{ include "postiz.chart" . }}
{{ include "postiz.selectorLabels" . }}
{{- end -}}

{{- define "postiz.selectorLabels" -}}
app.kubernetes.io/name: {{ include "postiz.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "postiz.name" -}}
{{ .Chart.Name }}
{{- end -}}

{{- define "postiz.chart" -}}
{{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}
