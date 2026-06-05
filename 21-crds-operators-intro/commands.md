# Commands — 21 CRDs & Operators Intro

---

## 1. Apply the CRD

```bash
kubectl apply -f manifests/crd.yaml
```

```bash
kubectl get crds
kubectl get crd widgets.lab.example.com
```

> What API group and version is the Widget resource in?

---

## 2. Inspect the CRD

```bash
kubectl describe crd widgets.lab.example.com
```

Look for:
- The `Validation` section — what fields are defined?
- The `Additional Printer Columns` section — what columns appear in `kubectl get`?
- The `Scope` — is this resource namespaced or cluster-wide?

```bash
kubectl get crd widgets.lab.example.com -o yaml | grep -A 40 "openAPIV3Schema:"
```

> What fields are `required`? What constraints does each field have?

---

## 3. Create the namespace

```bash
kubectl apply -f manifests/namespace.yaml
```

---

## 4. Create valid resources

```bash
kubectl apply -f manifests/widget-valid.yaml
kubectl apply -f manifests/widget-blue.yaml
```

```bash
kubectl get widgets -n lab-21-crds
```

> What columns does the output show? How did those columns get defined?

```bash
kubectl get widgets -n lab-21-crds -o wide
kubectl get wgt -n lab-21-crds
```

> The `wgt` shortname works — where is it defined in the CRD?

---

## 5. Inspect a custom resource

```bash
kubectl describe widget my-widget -n lab-21-crds
kubectl get widget my-widget -n lab-21-crds -o yaml
```

> What does the `status` field look like? Is there anything in it? Why or why not?

> Can you find the `message` field in the spec? Where is it in the output?

---

## 6. Patch a custom resource

```bash
kubectl patch widget my-widget -n lab-21-crds \
  --type=merge \
  -p '{"spec":{"message":"updated message"}}'
```

```bash
kubectl get widget my-widget -n lab-21-crds -o yaml | grep message
```

> Custom resources support standard kubectl operations. What else can you do with them?

---

## 7. Break it: invalid color (enum violation)

```bash
kubectl apply -f broken/widget-invalid-color.yaml
```

> What error did you get? Which field failed validation and why?

---

## 8. Break it: size exceeds maximum

```bash
kubectl apply -f broken/widget-invalid-size.yaml
```

> What error did you get? Is this an enum error or a range error?

---

## 9. Break it: missing required fields

```bash
kubectl apply -f broken/widget-missing-required.yaml
```

> What error did you get? What are the required fields?

---

## 10. Fix one broken resource

Edit `broken/widget-invalid-color.yaml` and fix the `color` field to one of: `red`, `blue`, `green`.

```bash
kubectl apply -f broken/widget-invalid-color.yaml
kubectl get widgets -n lab-21-crds
```

> How many widgets do you have now?

---

## 11. Compare to built-in resources

```bash
kubectl api-resources | grep widgets
kubectl api-resources | grep deployments
```

> How does the Widget resource appear in the API resource list? How is it similar to and different from Deployments?

```bash
kubectl api-versions | grep lab.example.com
```

> What API version did your CRD register?

---

## 12. Understand what the CRD does NOT do

When you created `my-widget`, nothing happened in the cluster except the resource was stored in etcd.

Compare this to creating a Deployment:
- Creating a Deployment → ReplicaSet controller creates pods → Scheduler assigns nodes → kubelet starts containers

Ask yourself:
> What would a Widget operator controller need to do when a Widget resource is created? What Kubernetes objects would it create or manage?

This is the conceptual gap between a CRD (data definition) and an operator (automation).

---

## 13. Explore real-world CRDs in your cluster

```bash
kubectl get crds
```

> If you installed the ingress-nginx or Calico from earlier labs, do you see any CRDs from those? What are they?

```bash
kubectl api-resources --api-group=networking.k8s.io
```

> Some built-in resources are defined as if they were CRDs. How does Kubernetes extend itself with its own API?

---

## 14. Delete a custom resource

```bash
kubectl delete widget my-widget -n lab-21-crds
kubectl get widgets -n lab-21-crds
```

> What happened? Was the Widget just a record in etcd, or did anything else get cleaned up?

---

## 15. Delete the CRD

```bash
kubectl delete crd widgets.lab.example.com
```

```bash
kubectl get widgets -n lab-21-crds 2>&1 || true
```

> What happened to the remaining Widget resources when the CRD was deleted?
> What does this tell you about the relationship between a CRD and its resources?
