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
chart version so bumping Chart.yaml's `version` drives both the chart
release and the image tag — no parallel appVersion to keep in sync.
*/}}
{{- define "fireseed.image" -}}
{{- $registry := .global.registry | default "" -}}
{{- $tag := .global.tag | default .chart.Version | default "latest" -}}
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

{{/*
Postgres connection helpers. These resolve to the external database when
postgres.external.enabled is true, otherwise to the bundled StatefulSet.
*/}}
{{- define "fireseed.postgresHost" -}}
{{- if .Values.postgres.external.enabled -}}
{{- required "postgres.external.host is required when postgres.external.enabled=true" .Values.postgres.external.host -}}
{{- else -}}
fireseed-postgres.{{ include "fireseed.namespace" . }}.svc.cluster.local
{{- end -}}
{{- end -}}

{{- define "fireseed.postgresPort" -}}
{{- if .Values.postgres.external.enabled -}}
{{- .Values.postgres.external.port | default 5432 -}}
{{- else -}}
{{- .Values.postgres.port | default 5432 -}}
{{- end -}}
{{- end -}}

{{- define "fireseed.postgresUser" -}}
{{- if .Values.postgres.external.enabled -}}
{{- .Values.postgres.external.user | default "fireseed" -}}
{{- else -}}
{{- .Values.postgres.user -}}
{{- end -}}
{{- end -}}

{{- define "fireseed.postgresDatabase" -}}
{{- if .Values.postgres.external.enabled -}}
{{- .Values.postgres.external.database | default "fireseed" -}}
{{- else -}}
{{- .Values.postgres.database -}}
{{- end -}}
{{- end -}}

{{/*
LiteLLM database name. Always `litellm` for in-cluster Postgres; for an
external database the operator must have CREATEDB / CREATEROLE so the
init job can provision it the same way.
*/}}
{{- define "fireseed.litellmDatabaseName" -}}
litellm
{{- end -}}

{{- define "fireseed.litellmDatabaseUser" -}}
litellm
{{- end -}}

{{/*
Pod placement (nodeSelector / affinity / tolerations). Applied uniformly
to every platform pod. Caller is responsible for indenting via nindent.
*/}}
{{- define "fireseed.podPlacement" -}}
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}
