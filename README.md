# ⎈ Buried-Marks Helm Infrastructure

Helm charts for Buried Marks microservices deployment on Kubernetes.

## Repository Structure

```bash
├── README.md
├── charts
│   ├── common             # Shared library chart with common templates
│   ├── admin-front        # Admin frontend chart
│   ├── login-front        # Login frontend chart
│   ├── map-front          # Map frontend chart
│   ├── voting-front       # Voting frontend chart
│   ├── auth-service       # Authentication microservice chart
│   ├── mail-service       # Mail microservice chart
│   ├── map-service        # Map microservice chart
│   └── voting-service     # Voting microservice chart
├── env                    # Environment files
├── helmfile.yaml          # Helmfile for simultaneously deploy all services at once
├── values
│   ├── dev-values.yaml    # Local deployment overrides
│   └── prod-values.yaml   # Production overrides
└── values.yaml            # Global default values
```

## Prerequisites

- [minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Fx86-64%2Fstable%2Fbinary+download) (for local setup)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [helm](https://helm.sh/docs/intro/install/)
- [helmfile](https://helmfile.readthedocs.io/en/latest/)
- [helm diff plugin](https://github.com/databus23/helm-diff)
- AWS CLI configured with access to ECR

<!-- ## Install Externel Secrets Operator

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets \
  --namespace external-secrets \
  --create-namespace
``` -->

## Local Deployment

### Create Namespace

```bash
kubectl create namespace buried-marks
```

### Create Secrets

Such local jwt file storage structure is required to use the following secret setup commands.

```tree
secrets
├── jwt_private_key
│   └── ec_private.key
└── jwt_public_key
    └── ec_public.key
```

```bash
# JWT keys
kubectl create secret generic jwt-public-key \
  --from-file=ec_public.key=secrets/jwt_public_key/ec_public.key \
  -n buried-marks

kubectl create secret generic jwt-private-key \
  --from-file=ec_private.key=secrets/jwt_private_key/ec_private.key \
  -n buried-marks

# AWS credentials for External Secrets Operator
kubectl create secret generic aws-sm-credentials \
  --from-literal=access-key=YOUR_AWS_ACCESS_KEY_ID \
  --from-literal=secret-access-key=YOUR_AWS_SECRET_ACCESS_KEY \
  -n buried-marks

# Service secrets
kubectl create secret generic map-service-secret --from-env-file=env/.env.map -n buried-marks
kubectl create secret generic auth-service-secret --from-env-file=env/.env.auth -n buried-marks
kubectl create secret generic mail-service-secret --from-env-file=env/.env.mail -n buried-marks
kubectl create secret generic voting-service-secret --from-env-file=env/.env.voting -n buried-marks
kubectl create secret generic front-secret --from-env-file=env/.env.front -n buried-marks
kubectl create secret generic map-front-secret --from-env-file=env/.env.map.front -n buried-marks
```

## Load Images into Minikube

### Authenticate with ECR

```bash
aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 531331080468.dkr.ecr.eu-north-1.amazonaws.com
```

### Pull and Load Images

```bash
minikube image load 531331080468.dkr.ecr.eu-north-1.amazonaws.com/buried-marks-map-microservice:latest
minikube image load 531331080468.dkr.ecr.eu-north-1.amazonaws.com/buried-marks-authentication-microservice:latest
minikube image load 531331080468.dkr.ecr.eu-north-1.amazonaws.com/buried-marks-mail-microservice:latest
minikube image load 531331080468.dkr.ecr.eu-north-1.amazonaws.com/buried-marks-voting-microservice:latest
minikube image load 531331080468.dkr.ecr.eu-north-1.amazonaws.com/buried-marks-login-front:latest
minikube image load 531331080468.dkr.ecr.eu-north-1.amazonaws.com/buried-marks-admin-front:latest
minikube image load 531331080468.dkr.ecr.eu-north-1.amazonaws.com/buried-marks-voting-front:latest
minikube image load 531331080468.dkr.ecr.eu-north-1.amazonaws.com/buried-marks-map-front:latest
```

## Helmfile

Instead of installing charts one by one, you can use `helmfile.yaml` to deploy all services at once:

```bash
# Install all services
helmfile -e dev apply

# Install specific service
helmfile -e dev apply -l name=map-service

# Sync specific environment
helmfile -e dev apply

# Destroy all releases
helmfile -e dev destroy
```
