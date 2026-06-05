# Lab 21 — CRDs & Operators Intro

## Goal

Understand how Kubernetes is extended through Custom Resource Definitions (CRDs) and how operators use this mechanism to manage complex applications as native Kubernetes objects.

## Teaches

- What a CRD is and how it extends the Kubernetes API
- How to define a CRD with OpenAPI v3 schema validation
- Creating and querying custom resources with kubectl
- Schema validation — how invalid resources are rejected at admission
- `additionalPrinterColumns` — custom fields in `kubectl get` output
- What an operator is and how it uses the CRD pattern
- The relationship between: CRD (schema) → Custom Resource (instance) → Controller (behavior)
- Why operators exist: encoding operational knowledge in code

## Prerequisites

- Lab 00 cluster running (`kind-config.yaml`)
- Comfortable with `kubectl apply` and basic resource inspection

## What You Will Build

A `Widget` CRD in the `lab.example.com` API group with:
- OpenAPI v3 schema validation (required fields, enum, min/max)
- Custom printer columns so `kubectl get widgets` shows Color, Size, and Age
- Two valid Widget instances
- Three invalid Widget instances that demonstrate schema rejection

You will NOT build an actual operator controller — that requires Go or Python coding outside the scope of this lab. Instead, you will deeply understand the CRD side (the data model) and conceptually map how an operator would react to resource changes.

## Files

```
manifests/
  namespace.yaml          — lab-21-crds namespace
  crd.yaml                — Widget CRD with schema validation and printer columns
  widget-valid.yaml       — my-widget: color=red, size=42
  widget-blue.yaml        — blue-widget: color=blue, size=7

broken/
  widget-invalid-color.yaml   — color=purple (not in enum)
  widget-invalid-size.yaml    — size=999 (exceeds maximum)
  widget-missing-required.yaml — missing color and size (required fields)
```

## Success Criteria

- `kubectl apply -f manifests/crd.yaml` succeeds
- `kubectl get crds` shows `widgets.lab.example.com`
- `kubectl apply -f manifests/widget-valid.yaml` succeeds
- `kubectl get widgets -n lab-21-crds` shows Color and Size columns
- All three broken widgets are rejected with schema validation errors
- `kubectl describe crd widgets.lab.example.com` shows the full schema
- You can explain what an operator controller does that this lab does not have

## Difficulty

Medium — CRDs are simple to create. The conceptual shift is understanding that a CRD alone is just a database record — without a controller watching for resource changes, nothing happens automatically.
