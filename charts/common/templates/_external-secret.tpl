{{/*
Common external secret template for AWS Secrets Manager
*/}}
{{- define "common.externalsecret" -}}
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: {{ include "common.fullname" . }}-secret
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: SecretStore
  target:
    name: {{ .Values.envSecret }}
    creationPolicy: Owner
  dataFrom:
    - extract:
        key: {{ index .Values.global.secrets .Chart.Name }}
{{- end }}
