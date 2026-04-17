# Fireseed

Fireseed is an AI-native application platform. Describe a tool in plain English; Fireseed writes the code, builds the containers, and runs them on your Kubernetes cluster.

## Install

This chart requires secrets to be pre-seeded via an existing Secret. See [`examples/secret.yaml`](examples/secret.yaml).

```bash
kubectl create namespace fireseed-system
kubectl apply -n fireseed-system -f examples/secret.yaml

helm install fireseed \
  oci://registry-1.docker.io/fireseeddev/fireseed \
  --version 1.0.7 \
  --namespace fireseed-system \
  --set existingSecret=fireseed-secrets
```

## What gets deployed

| Component | Purpose |
|-----------|---------|
| `fireseed-api` | FastAPI backend and AI agent |
| `fireseed-ui` | React frontend |
| `fireseed-operator` | Kubernetes operator for app workloads |
| `fireseed-litellm` | LiteLLM proxy → AWS Bedrock |
| `fireseed-postgres` | Platform database (StatefulSet + PVC) |
| `fireseed-redis` | Pub/sub for cross-pod WebSocket broadcast |
| `fireseed-squid` | Egress proxy with package-registry allow-list |
| `fireseed-browser` | Headless Playwright for AI verification |
| `fireseed-file-sync` | Sidecar that streams source into app pods |

## Secrets

- Plain Secret — [`examples/secret.yaml`](examples/secret.yaml)
- External Secrets Operator — [`examples/externalsecret.yaml`](examples/externalsecret.yaml)

Any method works as long as the Secret named by `existingSecret` contains the keys listed in [`examples/secret.yaml`](examples/secret.yaml).

## Configuration

Full defaults in [`helm/fireseed/values.yaml`](helm/fireseed/values.yaml). Common overrides:

```yaml
global:
  tag: "1.0.7"
  imagePullPolicy: IfNotPresent

ingress:
  enabled: true
  className: nginx
  host: fireseed.example.com
  tls: true
  tlsSecretName: fireseed-tls

api:
  replicas: 2
  resources:
    limits:
      cpu: 2000m
      memory: 2Gi
```

## Upgrading

```bash
helm upgrade fireseed \
  oci://registry-1.docker.io/fireseeddev/fireseed \
  --version 1.1.0 \
  --reuse-values
```

PostgreSQL's PVC survives `helm uninstall`.

## Licensing

Helm chart: [Apache 2.0](LICENSE).

Container images on `docker.io/fireseeddev/*` are free to use and valid for one year from the date each image is published.
