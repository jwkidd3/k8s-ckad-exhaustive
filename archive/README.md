# Archive

Material from earlier versions of the course that the current delivery (Cloud9 + kind, Reveal.js presentations, labs 00–31) no longer references. Kept in-tree for historical reference and easy restoration. Nothing in this directory is exercised by CI.

## Contents

### Legacy slide PDFs (superseded by `presentations/`)
- `K8s01.pdf`, `K8s02.pdf`, `slides.pdf` — the previous course deck
- `openshift.pdf` — OpenShift-specific material, out of scope for CKAD
- `k8s_diagram.pdf` — standalone architecture diagram

### Legacy setup / non-current environments
- `setup.md` — bare install snippets, replaced by `exercises/00-setup/instructions.md` which includes Cloud9, kind, cluster creation, and metrics-server
- `eks_cluster.yml` — eksctl config for EKS delivery; current delivery is Cloud9 + kind only

### Supplementary directories (not referenced by any current lab)
- `samples/` — reference YAMLs for affinity, taints, probes, etc. Up-to-date as of the most recent audit but not exercised in labs 00–31.
- `Microservices/` — Spring Boot `application.yml` files. Not Kubernetes manifests.
- `rvstore_hackathon/` — placeholder directory for a separate hackathon track.
- `rvstore_hackathon_solution/` — Kubernetes manifests for the hackathon's rvstore stack (elasticsearch, mongo, etc.). Was previously `exercises/solution/`.
- `nginx-pod.yaml` — scratch pod manifest, was previously at `exercises/nginx-pod.yaml`.

## Restoring something

```
git log --diff-filter=R --name-status -- archive/<file>
git mv archive/<file> <original-location>
```
