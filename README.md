# k8s-ckad-exhaustive

A hands-on Certified Kubernetes Application Developer (CKAD) course: 32 labs plus a 6-module slide deck, designed to run on AWS Cloud9 with a local kind cluster.

**Format:** 3 days, 9 AM – 4 PM, with a 1-hour lunch and two breaks. ~16.5 hours of instruction total, split **~70% hands-on labs / ~30% teaching** (≈11.5h lab time, ≈5h slide-driven instruction).

## Course Layout

```
exercises/
  00-setup/                 ← start here: Cloud9 + kind cluster bring-up
  01-container/             ← container image build
  02-pod/ … 31-networkpolicy/
presentations/
  module0_intro_setup.html
  module1_app_design_build.html
  module2_app_deployment.html
  module3_observability_maintenance.html
  module4_environment_config_security.html
  module5_services_networking.html
kind-config.yaml            ← 4-node kind cluster definition used by lab 00
components.yaml             ← metrics-server (with --kubelet-insecure-tls for kind)
archive/                    ← superseded material (legacy PDFs, EKS config, etc.)
```

## Getting Started

1. Open this repo in Cloud9.
2. Open `exercises/00-setup/instructions.md` and work through the cluster setup.
3. Each subsequent lab has its own `instructions.md` (the spec) and `lab/lab.md` (the step-by-step walkthrough students follow).
4. The presentations under `presentations/` interleave teaching slides with lab callouts — show them alongside the labs.

## CKAD Domain Coverage

| Module | Domain | Labs |
|---|---|---|
| 0 | Course intro &amp; setup | 00 |
| 1 | Application Design &amp; Build | 01–09, 14 |
| 2 | Application Deployment | 11–13, 15 |
| 3 | Observability &amp; Maintenance | 10, 16–19 |
| 4 | Environment, Config &amp; Security | 20–27 |
| 5 | Services &amp; Networking | 28–31 |

## Suggested Daily Plan

Balanced 11 / 11 / 10 labs across the three days. Modules 1 and 4 are the largest; Module 4 splits at the lab 21→22 boundary (CRD/RBAC closes Day 2, resource governance opens Day 3).

| Day | Theme | Modules | Labs | Count |
|---|---|---|---|---|
| Day 1 | Foundations | 0 + 1 | 00–09, 14 | 11 |
| Day 2 | Deployment, Ops, Identity | 2 + 3 + part of 4 | 10–13, 15–21 | 11 |
| Day 3 | Config, Security, Networking | rest of 4 + 5 | 22–31 | 10 |
