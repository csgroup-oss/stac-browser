{{/*
Expand the name of the chart.
*/}}
{{- define "stac-browser.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "stac-browser.fullname" -}}
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
Return the target namespace.
*/}}
{{- define "stac-browser.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "stac-browser.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "stac-browser.labels" -}}
helm.sh/chart: {{ include "stac-browser.chart" . }}
{{ include "stac-browser.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "stac-browser.selectorLabels" -}}
app.kubernetes.io/name: {{ include "stac-browser.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Build the application image reference.
*/}}
{{- define "stac-browser.image" -}}
{{- $registry := .Values.image.registry -}}
{{- $repository := .Values.image.repository -}}
{{- $digest := .Values.image.digest -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- $base := $repository -}}
{{- if $registry -}}
{{- $base = printf "%s/%s" $registry $repository -}}
{{- end -}}
{{- if and $tag $digest -}}
{{- printf "%s:%s@%s" $base $tag $digest -}}
{{- else if $digest -}}
{{- printf "%s@%s" $base $digest -}}
{{- else -}}
{{- printf "%s:%s" $base $tag -}}
{{- end -}}
{{- end }}

{{/*
Determine the path prefix from ingress or httproute.
Returns the path if it's not the root path "/", otherwise returns empty string.
This is used to automatically set SB_pathPrefix when deploying at a non-root path.
*/}}
{{- define "stac-browser.pathPrefix" -}}
{{- if and .Values.ingress.enabled (ne .Values.ingress.path "/") -}}
{{- .Values.ingress.path -}}
{{- else if .Values.httproute.enabled -}}
  {{- $prefix := "" -}}
  {{- if .Values.httproute.rules -}}
    {{- range .Values.httproute.rules -}}
      {{- if .matches -}}
        {{- range .matches -}}
          {{- if and .path .path.value (ne .path.value "/") -}}
            {{- $prefix = .path.value -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $prefix -}}
{{- end -}}
{{- end }}

{{/*
Render STAC Browser options as environment variables.
Expects a dict of options and renders them as SB_* environment variables.
*/}}
{{- define "stac-browser.optionsEnv" -}}
{{- range $key := keys . | sortAlpha }}
{{- $value := index . $key }}
- name: {{ printf "SB_%s" $key }}
  {{- if kindIs "string" $value }}
  value: {{ $value | quote }}
  {{- else }}
  value: {{ $value | toJson | quote }}
  {{- end }}
{{- end }}
{{- end }}
