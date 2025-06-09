# Postiz Helm Chart

This chart deploys the Postiz application along with optional PostgreSQL and Redis dependencies. It is optimized for running on AKS but is compatible with any Kubernetes cluster.

## Installing the Chart

```bash
helm dependency build charts/postiz
helm install postiz charts/postiz -n postiz --create-namespace
```

Customize deployments via `values.yaml`.
