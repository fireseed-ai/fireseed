{{/*
Install namespace. Prefers an explicit Values.namespace; otherwise uses
the release namespace passed via `helm install -n <ns>`.
*/}}
{{- define "fireseed.namespace" -}}
{{ .Values.namespace | default .Release.Namespace }}
{{- end -}}

{{- define "fireseed.labels" -}}
app.kubernetes.io/managed-by: helm
app.kubernetes.io/part-of: fireseed
{{- end -}}

{{/*
Build image reference: registry/name:tag. The tag falls back to the
chart's appVersion so each chart release pins its matching image tag.
*/}}
{{- define "fireseed.image" -}}
{{- $registry := .global.registry | default "" -}}
{{- $tag := .global.tag | default .chart.AppVersion | default "latest" -}}
{{- if $registry -}}
{{ $registry }}/{{ .name }}:{{ $tag }}
{{- else -}}
{{ .name }}:{{ $tag }}
{{- end -}}
{{- end -}}

{{/*
Name of the Secret holding platform credentials. Required — the chart
intentionally does not create this for you; see examples/secret.yaml.
*/}}
{{- define "fireseed.secretName" -}}
{{ required "existingSecret is required — create a Secret with the keys listed in values.yaml and set .Values.existingSecret to its name. See examples/secret.yaml." .Values.existingSecret }}
{{- end -}}

{{/*
Image pull secrets block — renders only if configured.
*/}}
{{- define "fireseed.imagePullSecrets" -}}
{{- if .Values.global.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml .Values.global.imagePullSecrets | nindent 8 }}
{{- end }}
{{- end -}}
