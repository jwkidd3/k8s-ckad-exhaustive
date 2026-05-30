# k8s-ckad-exhaustive

A hands-on Certified Kubernetes Application Developer (CKAD) course: 32 labs plus a 6-module slide deck, designed to run on AWS Cloud9 with a local kind cluster.

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
3. Each subsequent lab has its own `instructions.md` and `solution/` directory.
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
