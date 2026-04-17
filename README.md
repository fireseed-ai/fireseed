# Fireseed

Fireseed is an AI-native application platform. Describe a tool in plain English; Fireseed writes the code, builds the containers, and runs them on your Kubernetes cluster.

This repository contains the Helm chart for deploying Fireseed to your own cluster.

---

## Install

```bash
# 1. Create the Secret that holds your credentials (see examples/secret.yaml)
kubectl create namespace fireseed-system
kubectl apply -n fireseed-system -f examples/secret.yaml

# 2. Install the chart
helm install fireseed \
  oci://registry-1.docker.io/fireseeddev/fireseed \
  --version 1.1.0 \
  --namespace fireseed-system \
  --set existingSecret=fireseed-secrets
```

The chart deploys nine services to a single namespace:

| Component | What it does |
|-----------|--------------|
| `fireseed-api` | FastAPI backend, serves the UI and the AI agent |
| `fireseed-ui` | React frontend |
| `fireseed-operator` | Kubernetes operator, provisions app workloads |
| `fireseed-litellm` | LiteLLM proxy in front of AWS Bedrock |
| `fireseed-postgres` | Platform database (StatefulSet with PVC) |
| `fireseed-redis` | Pub/sub for cross-pod WebSocket broadcast |
| `fireseed-squid` | Egress proxy with an allow-list of package registries |
| `fireseed-browser` | Headless Playwright browser for AI verification |
| `fireseed-file-sync` | Sidecar that streams source files into app pods |

---

## Configuration

### Required values

- `existingSecret` — name of a Secret in the install namespace containing credentials. See [`examples/secret.yaml`](examples/secret.yaml) for the required keys.

### Common overrides

```yaml
global:
  tag: "1.1.0"              # image tag; defaults to chart appVersion
  imagePullPolicy: IfNotPresent

ingress:
  enabled: true
  className: nginx          # empty uses the cluster's default IngressClass
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

See [`helm/fireseed/values.yaml`](helm/fireseed/values.yaml) for the complete list.

---

## Secrets

The chart does not create or manage the Secret — that keeps sensitive values out of `values.yaml` and out of your git history.

Pick whichever fits your workflow:

- **Plain Secret**: copy and fill in [`examples/secret.yaml`](examples/secret.yaml), then `kubectl apply`
- **External Secrets Operator**: see [`examples/externalsecret.yaml`](examples/externalsecret.yaml)
- **Sealed Secrets, SOPS, Vault Agent**: create the Secret however you normally would; set `existingSecret` to its name

---

## Upgrading

```bash
helm upgrade fireseed \
  oci://registry-1.docker.io/fireseeddev/fireseed \
  --version 1.2.0 \
  --reuse-values
```

The bundled PostgreSQL StatefulSet's PVC survives `helm uninstall`, so data is preserved across a full reinstall.

---

## Licensing

The Helm chart in this repository is Apache 2.0 — see [`LICENSE`](LICENSE).

Container images published to `docker.io/fireseeddev/*` are free to use and valid for one year from the date each image is published. Each release rebuilds the images with a freshly-signed licence.
