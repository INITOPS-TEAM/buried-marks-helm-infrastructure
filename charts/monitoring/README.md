# Monitoring Stack

Prometheus + Grafana + Alertmanager monitoring setup using kube-prometheus-stack.

## Overview

This chart deploys:

- **Prometheus**: Metrics about cluster components and buried-marks application (kube-prometheus-stack)
- **Grafana**: Visualization and dashboards
- **Alertmanager**: Alert notifications (Slack)

## Installation

### Add Prometheus Repository

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### Install Monitoring Stack

```bash
helm install monitoring ./charts/monitoring \
  -n monitoring \
  --create-namespace \
  -f values/dev-values.yaml
```

## Accessing Services

### Prometheus

```bash
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090
# Access: http://localhost:9090
```

### Grafana

```bash
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
# Access: http://localhost:3000
```

### Alertmanager

```bash
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-alertmanager 9093:9093
# Access: http://localhost:9093
```

### Blackbox Exporter (short)

```bash
kubectl port-forward -n monitoring svc/monitoring-prometheus-blackbox-exporter 9115:9115
```

## Environment Variables

Used variables:

- **GRAFANA_ADMIN_PASSWORD** – Grafana admin password
- **SLACK_API_URL** – Slack webhook URL
- **SLACK_CHANNEL** – Slack channel for alerts

Examples:

- **GRAFANA_ADMIN_PASSWORD** – admin
- **SLACK_API_URL** – https://hooks.slack.com/services/YOUR/WEBHOOK/URL
- **SLACK_CHANNEL** – "#alerts"

## Slack Integration

### Configure Slack Webhook

1. Create incoming webhook in Slack workspace
2. Update `values.yaml`:

```yaml
alertmanager:
  config:
    global:
    resolve_timeout: 5m
    route:
    receiver: "slack"
    receivers:
    - name: "slack"
        slack_configs:
        - api_url: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL" # UPDATE THIS
            channel: "#channel-name" # UPDATE THIS
```

## Dependencies

- kube-prometheus-stack: 82.15.0+
- prometheus-blackbox-exporter: 11.9.1+

## Notes

- Slack webhook URL should be configured
