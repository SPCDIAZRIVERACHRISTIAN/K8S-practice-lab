# Solutions — 20 Helm & Kustomize

---

## Kustomize

### What Kustomize does

Kustomize is a configuration transformation tool built into kubectl. It does not use templates — instead it transforms plain YAML manifests using a declarative set of operations defined in `kustomization.yaml`.

The base + overlay model:
- **Base** — the canonical, environment-agnostic resource definitions. No namespaces, no environment-specific values.
- **Overlay** — a thin layer on top of the base that applies transformations: namespace, namePrefix, image tags, replica counts, patches.

An overlay does not duplicate the base. It references it (`resources: - ../../base`) and applies changes on top.

### How each field works

**`namespace`:** Sets the namespace on all resources in the overlay. Without this, resources inherit whatever is (or isn't) set in the base.

**`namePrefix`:** Prepends a string to every resource name. `webapp` becomes `dev-webapp`. This allows the same base resources to coexist in the same namespace without name collision — but in this lab, different namespaces make the prefix optional. It's a common pattern for multi-tenant clusters.

**`images`:** Replaces image tags without editing the base deployment. The `name: nginx` field matches the container image name, and `newTag: "1.25"` replaces only the tag. This lets you pin different versions per environment without touching base files.

**`commonLabels`:** Adds labels to all generated resources. The `managed-by: kustomize` label in the base propagates to all objects created from it.

**`patches` (JSON 6902):** The lab uses JSON patch format (RFC 6902). The `op: replace` operation replaces a value at a JSON path. `path: /spec/replicas` targets the Deployment's replica count. The `target` field identifies which resource to patch.

### Why Kustomize avoids templating

Templating (like Helm's `{{ .Values.replicas }}`) turns YAML into a mini-programming language. You must render the template to see what will actually apply. Kustomize operates on plain, valid YAML — you can read and apply the base files directly without any rendering step. The transformation is explicit and traceable.

The limitation is power: Kustomize can transform values that exist but cannot generate values conditionally, loop over lists, or apply complex logic. Helm can do all of those things.

### `kubectl kustomize` vs `kubectl apply -k`

```bash
kubectl kustomize dir/   # renders to stdout, no apply
kubectl apply -k dir/    # renders and applies to the cluster
```

Use `kubectl kustomize` to review what will be applied before committing. It is the Kustomize equivalent of `helm template`.

---

## Helm

### Charts and releases

A **chart** is a packaged Kubernetes application — a directory (or archive) containing templates, a `values.yaml` with defaults, and a `Chart.yaml` with metadata.

A **release** is a running instance of a chart in a cluster. You can install the same chart multiple times under different release names. Each release has its own state tracked by Helm in a Kubernetes Secret.

### What `helm install` does beyond `kubectl apply`

1. Renders the chart templates with merged values (defaults + your overrides)
2. Applies the rendered manifests to the cluster
3. Records the release in a Kubernetes Secret (`sh.helm.release.v1.<name>.v<rev>`) in the release namespace
4. Assigns a revision number (starts at 1)

The release record is what enables upgrade, rollback, and history. `kubectl apply` has no equivalent concept of revisions.

### Why rollback revision is NOT 1

Helm never goes backwards in revision numbers. A rollback is a new revision. If you installed at revision 1, upgraded to revision 2, and rolled back, the new state is revision 3 — but the deployed manifests match revision 1.

```
rev 1: install   (1 replica)
rev 2: upgrade   (3 replicas)
rev 3: rollback  (1 replica, matching rev 1)
```

This allows you to audit the full history of every change, including rollbacks.

### `helm get values` and `helm get manifest`

```bash
helm get values my-nginx -n lab-20-helm    # shows user-supplied values only
helm get values my-nginx -n lab-20-helm -a # shows all values including defaults
helm get manifest my-nginx -n lab-20-helm  # shows the rendered Kubernetes YAML
```

These are useful when debugging a running release — you can see exactly what Helm applied without re-rendering the chart.

### `--set` vs `--values`

- `--set key=value` — inline override, convenient for one-off values
- `--values file.yaml` — file-based override, good for environment-specific config tracked in git

When both are provided, `--set` wins over `--values` file. When upgrading, values from the previous revision are NOT remembered — you must provide them again or use `--reuse-values`.

---

## Helm vs Kustomize

| | Kustomize | Helm |
|--|-----------|------|
| Templates | No — plain YAML transformations | Yes — Go template language |
| Learning curve | Low | Medium-High (templating, hooks, functions) |
| Environment differences | Overlays | Values files or `--set` |
| Installing third-party apps | Poor — no chart ecosystem | Strong — thousands of charts on ArtifactHub |
| GitOps friendliness | High — rendered output is plain YAML | Medium — must render first |
| Versioned releases | No | Yes — full install/upgrade/rollback/history |
| CRD management | Manual | Built-in chart hooks |

**Choose Helm when:**
- Installing a third-party application with complex configuration (Prometheus, cert-manager, ArgoCD)
- Building a reusable package for others to install
- You need versioned release management and rollback

**Choose Kustomize when:**
- You own the base manifests and need environment-specific variations
- You are patching manifests you do not control (e.g., an upstream deployment YAML)
- You want plain YAML in git that can be applied directly without rendering
- You are in a GitOps workflow with Flux or ArgoCD

**Both together:** A common pattern is to use Helm for third-party installs and Kustomize for your own application manifests. Some teams use Kustomize to patch Helm-rendered output (render Helm to a file, then Kustomize-patch it).

---

## CKA coverage

Helm and Kustomize appear in the CKA exam at a basic level. Expect to:
- Use `kubectl apply -k` to deploy from a Kustomize directory
- Use `helm install` and `helm upgrade` to manage a release
- Interpret `helm list` and `helm history` output
- Know that `kubectl kustomize` renders without applying

You are not expected to write chart templates or complex Kustomize transformations from scratch on the CKA.
