# Commands — 20 Helm & Kustomize

---

## Part 1: Kustomize

---

### 1. Preview the base

```bash
kubectl kustomize kustomize/base
```

> What does this output? Does the base have a namespace set?

---

### 2. Preview the dev overlay

```bash
kubectl kustomize kustomize/overlays/dev
```

> How many replicas does the Deployment have? What image tag is set? What namespace?

Look for these fields in the output:
- `namespace:`
- `replicas:`
- `image:`
- `labels:`

---

### 3. Preview the prod overlay

```bash
kubectl kustomize kustomize/overlays/prod
```

> How do the prod manifests differ from dev?

Compare: replicas, image tag, namePrefix, namespace, labels.

---

### 4. Apply dev

```bash
kubectl create namespace lab-20-dev
kubectl apply -k kustomize/overlays/dev
```

```bash
kubectl get all -n lab-20-dev
```

> What are the Deployment and Service names? How do they differ from the base names?

---

### 5. Apply prod

```bash
kubectl create namespace lab-20-prod
kubectl apply -k kustomize/overlays/prod
```

```bash
kubectl get all -n lab-20-prod
```

> How many replicas in prod vs dev?

---

### 6. Verify the labels

```bash
kubectl get pods -n lab-20-dev --show-labels
kubectl get pods -n lab-20-prod --show-labels
```

> What labels does each pod have? Where did the `managed-by: kustomize` label come from?

---

### 7. Change the dev replica count via overlay patch

Edit `kustomize/overlays/dev/kustomization.yaml` and change the replica patch value from `1` to `2`.

```bash
kubectl apply -k kustomize/overlays/dev
kubectl get deployment dev-webapp -n lab-20-dev
```

> What happened to the Deployment? How is this different from editing the base?

Change it back to `1` when done:

```bash
# edit kustomization.yaml back to 1, then:
kubectl apply -k kustomize/overlays/dev
```

---

### 8. Render to a file

```bash
kubectl kustomize kustomize/overlays/prod > /tmp/prod-rendered.yaml
cat /tmp/prod-rendered.yaml
```

> Why might you want to render Kustomize output to a file instead of piping directly to apply?

---

### 9. Understand what Kustomize is NOT doing

Open `kustomize/base/deployment.yaml`. Notice there are no `{{ .Values.replicas }}` template variables. Kustomize uses transformations on plain YAML — it does not template strings.

> What is the advantage of this approach? What is the limitation compared to Helm?

---

## Part 2: Helm

---

### 10. Verify Helm is installed

```bash
helm version
```

> What version of Helm is installed?

---

### 11. Add the Bitnami repo

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

```bash
helm search repo bitnami/nginx
```

> What is the current chart version and app version?

---

### 12. Preview a Helm chart without installing

```bash
helm template my-nginx bitnami/nginx --namespace lab-20-helm | head -80
```

> What Kubernetes objects does this chart create? Can you find the Deployment, Service, and ConfigMap in the output?

---

### 13. Install the chart

```bash
kubectl create namespace lab-20-helm
helm install my-nginx bitnami/nginx \
  --namespace lab-20-helm \
  --set replicaCount=1
```

```bash
helm list -n lab-20-helm
kubectl get all -n lab-20-helm
```

> What is the release name? What is the release status?

---

### 14. Inspect the release

```bash
helm status my-nginx -n lab-20-helm
helm get values my-nginx -n lab-20-helm
helm get manifest my-nginx -n lab-20-helm | head -40
```

> What does `helm get manifest` show? How is this different from `kubectl get ... -o yaml`?

---

### 15. Upgrade the release

```bash
helm upgrade my-nginx bitnami/nginx \
  --namespace lab-20-helm \
  --set replicaCount=3
```

```bash
helm list -n lab-20-helm
kubectl get deployment -n lab-20-helm
```

> What revision number is the release now? How many replicas does the Deployment have?

---

### 16. View the release history

```bash
helm history my-nginx -n lab-20-helm
```

> What does the history show? What was the change between revision 1 and revision 2?

---

### 17. Rollback to revision 1

```bash
helm rollback my-nginx 1 -n lab-20-helm
```

```bash
helm history my-nginx -n lab-20-helm
kubectl get deployment -n lab-20-helm
```

> What revision number is it now after rollback? How many replicas does the Deployment have?

> Why is the revision number NOT back to 1 after rollback?

---

### 18. Upgrade with a values file (optional)

Create a file `/tmp/my-values.yaml`:
```yaml
replicaCount: 2
service:
  type: ClusterIP
```

```bash
helm upgrade my-nginx bitnami/nginx \
  --namespace lab-20-helm \
  --values /tmp/my-values.yaml
```

> How does `--values` differ from `--set`? Which takes precedence when both are provided?

---

### 19. Uninstall the release

```bash
helm uninstall my-nginx -n lab-20-helm
```

```bash
kubectl get all -n lab-20-helm
helm list -n lab-20-helm
```

> What happened to the Kubernetes objects? What happened to the release history?

---

## Helm vs Kustomize

Consider these scenarios. Which tool would you use?

| Scenario | Tool |
|----------|------|
| Deploy the same app to dev/staging/prod with minor config differences | ? |
| Install a third-party application (Prometheus, cert-manager, ingress-nginx) | ? |
| Override one field in a manifest you don't control | ? |
| Build a reusable, parameterized package for others to install | ? |
| Apply GitOps-style declarative patches tracked in git | ? |
