{{/*
Common secret store template for AWS Secrets Manager
*/}}
{{- define "common.secretstore" -}}
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: aws-secrets-manager
  namespace: {{ .Release.Namespace }}
spec:
  provider:
    aws:
      service: SecretsManager
      region: {{ .Values.global.aws.region | default "eu-north-1" }}
      auth:
        secretRef:
          accessKeyIDSecretRef:
            name: awssm-credentials
            key: access-key
          secretAccessKeySecretRef:
            name: awssm-credentials
            key: secret-access-key
{{- end }}
