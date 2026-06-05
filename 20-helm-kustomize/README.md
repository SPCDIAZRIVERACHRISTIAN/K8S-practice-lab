# Lab 20 — Helm & Kustomize

## Goal

Learn the two dominant Kubernetes configuration management tools: Kustomize (built into kubectl) for layered manifest customization, and Helm for templated application packaging. Understand when to reach for each tool.

## Teaches

**Kustomize:**
- base + overlays pattern — one set of manifests, environment-specific customization
- `kubectl apply -k` — apply a Kustomize directory
- `kubectl kustomize` — render output without applying
- `namePrefix`, `namespace`, `commonLabels`, `images`, `patches`
- Strategic merge patch vs JSON 6902 patch
- Why Kustomize avoids templating in favor of transformation

**Helm:**
- Charts, releases, repositories
- `helm install`, `helm upgrade`, `helm rollback`, `helm uninstall`
- `helm list`, `helm history` — managing release state
- `--set` vs `--values` for overrides
- `helm template` — render a chart without installing
- Helm vs Kustomize: when to use which

## Prerequisites

- Lab 00 cluster running (`kind-config.yaml`)
- **Helm 3 must be installed:** `helm version`
  Install: https://helm.sh/docs/intro/install/

## What You Will Build

**Kustomize:**
A webapp (nginx) deployed to two namespaces with different configurations:
- `lab-20-dev` — 1 replica, nginx:1.25 image tag, `env: dev` label
- `lab-20-prod` — 3 replicas, nginx:stable image tag, `env: prod` label

Both environments share the same base manifests. Only the overlay files differ.

**Helm:**
Install bitnami/nginx via Helm into `lab-20-helm`. Upgrade it with a custom value, then roll it back.

## Files

```
kustomize/
  base/
    deployment.yaml           — base webapp Deployment (2 replicas, plain nginx)
    service.yaml              — base webapp Service
    kustomization.yaml        — base kustomization: lists resources, adds managed-by label

  overlays/
    dev/
      kustomization.yaml      — dev overlay: namespace, namePrefix, nginx:1.25, 1 replica
    prod/
      kustomization.yaml      — prod overlay: namespace, namePrefix, nginx:stable, 3 replicas
```

## Success Criteria

**Kustomize:**
- `kubectl kustomize kustomize/overlays/dev` renders a Deployment with 1 replica, image `nginx:1.25`, namespace `lab-20-dev`
- `kubectl kustomize kustomize/overlays/prod` renders a Deployment with 3 replicas, image `nginx:stable`, namespace `lab-20-prod`
- After `kubectl apply -k`: dev has 1 pod, prod has 3 pods
- Objects are named with the correct prefix (`dev-webapp`, `prod-webapp`)

**Helm:**
- `helm install` deploys bitnami/nginx to `lab-20-helm`
- `helm upgrade` changes replica count
- `helm history` shows two revisions
- `helm rollback` restores revision 1
- `helm list` shows the release status

## Difficulty

Medium — Kustomize is intuitive once you see the base/overlay pattern. Helm's templating system is deeper than this lab goes, but the release management workflow maps to git concepts.
