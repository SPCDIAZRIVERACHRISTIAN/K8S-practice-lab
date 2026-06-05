# Kubernetes Observability Tools — Notes

Tracking existing tools per observability category. If a tool exists and is active, it is listed with a link. If it is deprecated with no solid maintained replacement, it goes in the **To Build** list.

---

## The Three Pillars

### Metrics

| Tool | Status | Link |
|------|--------|------|
| Prometheus | Active (CNCF Graduated) | https://prometheus.io |
| metrics-server | Active | https://github.com/kubernetes-sigs/metrics-server |
| kube-state-metrics | Active | https://github.com/kubernetes/kube-state-metrics |
| Node Exporter | Active | https://github.com/prometheus/node_exporter |
| Heapster | **DEPRECATED** (since K8s 1.11) — replaced by metrics-server | https://github.com/kubernetes-retired/heapster |

### Logging

| Tool | Status | Link |
|------|--------|------|
| Fluent Bit | Active | https://fluentbit.io |
| Fluentd | Active | https://www.fluentd.org |
| Grafana Loki | Active | https://grafana.com/oss/loki |
| Elasticsearch + Kibana (ELK) | Active | https://www.elastic.co/elastic-stack |

### Distributed Tracing

| Tool | Status | Link |
|------|--------|------|
| Jaeger | Active (CNCF Graduated) | https://www.jaegertracing.io |
| Grafana Tempo | Active | https://grafana.com/oss/tempo |
| Zipkin | Active | https://zipkin.io |

---

## Visualization & Dashboards

| Tool | Status | Link |
|------|--------|------|
| Grafana | Active | https://grafana.com |
| Headlamp | Active (recommended K8s Dashboard replacement) | https://headlamp.dev |
| Kubernetes Dashboard | **DEPRECATED** — unmaintained, migrate to Headlamp | https://github.com/kubernetes/dashboard |

---

## Alerting

| Tool | Status | Link |
|------|--------|------|
| Prometheus Alertmanager | Active | https://prometheus.io/docs/alerting/latest/alertmanager |

---

## Unified Collection

| Tool | Status | Link |
|------|--------|------|
| OpenTelemetry Collector | Active (CNCF — industry standard) | https://opentelemetry.io/docs/collector |

---

## To Build

Tools that are deprecated and whose replacements are either external SaaS, too heavy, or don't fully cover the use case — good candidates for building custom lightweight versions as exercises.

- [ ] **Cluster resource dashboard** — Kubernetes Dashboard is deprecated and Headlamp is GUI-only. Build a lightweight CLI or web dashboard that shows pod/node resource usage pulling from metrics-server.
- [ ] **Heapster-style aggregator** — Heapster is retired. Build a simple metrics aggregator that scrapes kubelet endpoints and exposes aggregated CPU/memory per namespace/deployment.

---

## Notes

- **OpenTelemetry** is the current industry standard for instrumentation. Most backends (Prometheus, Jaeger, Grafana, Datadog, etc.) now accept OTLP natively. Any new tooling should speak OTLP.
- The most common open-source stack in 2026: **Prometheus + Grafana + Loki + Tempo + OTel Collector**.
