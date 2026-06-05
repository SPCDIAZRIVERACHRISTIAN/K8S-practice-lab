# Commands — 18 RBAC & ServiceAccounts

Work through each section. After every command, answer the observation question in `notes.md`.

---

## 1. Apply the base manifests

```bash
kubectl apply -f manifests/namespace.yaml
kubectl apply -f manifests/serviceaccount.yaml
kubectl apply -f manifests/role.yaml
kubectl apply -f manifests/rolebinding.yaml
kubectl apply -f manifests/target-deployment.yaml
kubectl apply -f manifests/test-pod.yaml
```

Wait for everything to be ready:

```bash
kubectl get all -n lab-18-rbac
kubectl wait --for=condition=Ready pod/rbac-tester -n lab-18-rbac --timeout=60s
```

---

## 2. Inspect the ServiceAccount

```bash
kubectl describe serviceaccount lab-reader -n lab-18-rbac
```

> What fields do you see on a ServiceAccount? Does it have a token mounted automatically?

```bash
kubectl get serviceaccount lab-reader -n lab-18-rbac -o yaml
```

> Where does the service account token get mounted in a pod?

---

## 3. Inspect the Role

```bash
kubectl describe role pod-reader -n lab-18-rbac
```

> What does `apiGroups: [""]` mean? What are the three parts of an RBAC rule?

```bash
kubectl get role pod-reader -n lab-18-rbac -o yaml
```

---

## 4. Inspect the RoleBinding

```bash
kubectl describe rolebinding lab-reader-binding -n lab-18-rbac
```

> What three pieces of information does a RoleBinding contain?

---

## 5. Audit permissions with kubectl auth can-i

```bash
# Can the ServiceAccount list pods in this namespace?
kubectl auth can-i list pods -n lab-18-rbac \
  --as=system:serviceaccount:lab-18-rbac:lab-reader

# Can it get a specific pod?
kubectl auth can-i get pods -n lab-18-rbac \
  --as=system:serviceaccount:lab-18-rbac:lab-reader

# Can it delete deployments?
kubectl auth can-i delete deployments -n lab-18-rbac \
  --as=system:serviceaccount:lab-18-rbac:lab-reader

# Can it list pods in the default namespace?
kubectl auth can-i list pods -n default \
  --as=system:serviceaccount:lab-18-rbac:lab-reader

# Can it list pods cluster-wide?
kubectl auth can-i list pods --all-namespaces \
  --as=system:serviceaccount:lab-18-rbac:lab-reader
```

> What does the namespace boundary mean for a Role vs a ClusterRole?

---

## 6. Prove it from inside the pod

```bash
kubectl exec -it rbac-tester -n lab-18-rbac -- kubectl get pods -n lab-18-rbac
```

> Did it succeed? What token is it using to make that API call?

```bash
kubectl exec -it rbac-tester -n lab-18-rbac -- kubectl delete deployment sample-app -n lab-18-rbac
```

> What error did you get? What HTTP status code does Forbidden map to?

---

## 7. Examine the mounted token

```bash
kubectl exec -it rbac-tester -n lab-18-rbac -- \
  ls /var/run/secrets/kubernetes.io/serviceaccount/
```

> What three files are mounted? What is each used for?

```bash
kubectl exec -it rbac-tester -n lab-18-rbac -- \
  cat /var/run/secrets/kubernetes.io/serviceaccount/namespace
```

---

## 8. Break it: empty Role

```bash
kubectl apply -f broken/role-empty.yaml
```

> The RoleBinding still exists. Does the ServiceAccount still have permissions?

```bash
kubectl auth can-i list pods -n lab-18-rbac \
  --as=system:serviceaccount:lab-18-rbac:lab-reader
```

> Why did permissions change even though you did not touch the RoleBinding?

---

## 9. Fix it: restore the Role

```bash
kubectl apply -f manifests/role.yaml
```

```bash
kubectl auth can-i list pods -n lab-18-rbac \
  --as=system:serviceaccount:lab-18-rbac:lab-reader
```

> What does this tell you about how RBAC is evaluated at request time vs at binding creation time?

---

## 10. Break it: wrong subject in RoleBinding

```bash
kubectl apply -f broken/rolebinding-wrong-sa.yaml
```

```bash
kubectl auth can-i list pods -n lab-18-rbac \
  --as=system:serviceaccount:lab-18-rbac:lab-reader
```

> The Role has the right rules. Why does the ServiceAccount still have no permissions?

---

## 11. Fix it: restore the RoleBinding

```bash
kubectl apply -f manifests/rolebinding.yaml
```

```bash
kubectl auth can-i list pods -n lab-18-rbac \
  --as=system:serviceaccount:lab-18-rbac:lab-reader
```

---

## 12. ClusterRole vs Role — observe the difference

```bash
kubectl get clusterroles | head -20
kubectl describe clusterrole view
```

> The built-in `view` ClusterRole can read most resources cluster-wide. How is a ClusterRole different from a Role in terms of scope?

```bash
# Bind the built-in 'view' ClusterRole to the ServiceAccount with a RoleBinding
# (Note: using a ClusterRole with a RoleBinding scopes it to the namespace)
kubectl create rolebinding view-in-ns \
  --clusterrole=view \
  --serviceaccount=lab-18-rbac:lab-reader \
  -n lab-18-rbac \
  --dry-run=client -o yaml
```

> If you apply this, would the ServiceAccount gain cluster-wide view access?

---

## 13. List everything the ServiceAccount can do

```bash
kubectl auth can-i --list -n lab-18-rbac \
  --as=system:serviceaccount:lab-18-rbac:lab-reader
```

> How does this help you audit permissions during a security review?
