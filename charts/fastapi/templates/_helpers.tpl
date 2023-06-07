{{/*
Expand the name of the chart.
*/}}
{{- define "fastapi-helm-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fastapi-helm-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fastapi-helm-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fastapi-helm-chart.labels" -}}
helm.sh/chart: {{ include "fastapi-helm-chart.chart" . }}
{{ include "fastapi-helm-chart.selectorLabels" . }}
{{- if or .Values.image.tag .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fastapi-helm-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fastapi-helm-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "fastapi-helm-chart.webSelectorLabels" -}}
{{ include "fastapi-helm-chart.selectorLabels" . }}
app.kubernetes.io/component: web
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "fastapi-helm-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fastapi-helm-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "fastapi-helm-chart.l5d-dst-override" -}}
{{- if .Values.ingress.haproxyL5dDstOverride }}
{{- $svcPort := .Values.service.port -}}
haproxy.org/request-set-header: l5d-dst-override {{ include "fastapi-helm-chart.fullname" . }}.{{ .Release.Namespace | default .Values.namespace }}.svc.cluster.local:{{ $svcPort }}
{{- end }}
{{- end }}

{{- define "fastapi-helm-chart.monitoring-config" -}}
ELASTIC_APM_SERVICE_NAME: "{{ include "fastapi-helm-chart.fullname" . }}"
ELASTIC_APM_SERVER_URL: "http://apm-server.{{ .Release.Namespace | default .Values.namespace }}.svc.cluster.local:8200"
ELASTIC_APM_ENVIRONMENT: "{{ .Release.Namespace | default .Values.namespace }}"
ELASTIC_APM_CLOUD_PROVIDER: "gcp"
ELASTIC_APM_CENTRAL_CONFIG: "false"
ELASTIC_APM_SERVER_TIMEOUT: "10s"
SENTRY_ENVIRONMENT: "{{ .Release.Namespace | default .Values.namespace }}"
{{- end }}

{{- define "fastapi-helm-chart.defaultPodAnnotations" -}}
co.elastic.logs/json.keys_under_root: "true"
co.elastic.logs/json.overwrite_keys: "true"
co.elastic.logs/json.add_error_key: "true"
co.elastic.logs/json.expand_keys: "true"
{{- end }}
