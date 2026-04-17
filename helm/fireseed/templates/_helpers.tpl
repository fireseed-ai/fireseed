{{- define "fireseed.namespace" -}}
{{ .Values.namespace | default "fireseed-system" }}
{{- end -}}

{{- define "fireseed.labels" -}}
app.kubernetes.io/managed-by: helm
app.kubernetes.io/part-of: fireseed
{{- end -}}

{{/*
Build image reference: registry/name:tag or just name:tag for local dev
*/}}
{{- define "fireseed.image" -}}
{{- $registry := .global.registry | default "" -}}
{{- if $registry -}}
{{ $registry }}/{{ .name }}:{{ .global.tag | default "latest" }}
{{- else -}}
{{ .name }}:{{ .global.tag | default "latest" }}
{{- end -}}
{{- end -}}

{{/*
Secret name — use existingSecret if set, otherwise the chart-managed one
*/}}
{{- define "fireseed.secretName" -}}
{{ .Values.existingSecret | default "fireseed-secrets" }}
{{- end -}}

{{/*
Image pull secrets — renders imagePullSecrets block if configured
*/}}
{{- define "fireseed.imagePullSecrets" -}}
{{- if .Values.global.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml .Values.global.imagePullSecrets | nindent 8 }}
{{- end }}
{{- end -}}
