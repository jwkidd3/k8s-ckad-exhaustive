# Lab 31


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `k1`, `k2`<br>
* Documentation: [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/), [Pods](https://kubernetes.io/docs/concepts/workloads/pods/)

</p>
</details>

All ingress Pod-to-Pod communication has been denied across all namespaces. You want to allow the Pod `busybox` in namespace `k1` to communicate with Pod `nginx` in namespace `k2`. You'll create a network policy to achieve that.

> **_NOTE:_** Without a network policy controller, network policies won't have any effect. You need to configure a network overlay solution that provides this controller. You'll have to go through some extra steps to install and enable the network provider Cilium. Without adhering to the proper prerequisites, network policies won't have any effect. You can find installation guidance in the file [cilium-setup.md](./cilium-setup.md). If you do not already have a cluster, you can create one by using minikube or you can use the Katacoda lab ["Creating a Network Policy"](https://learning.oreilly.com/scenarios/ckad-services-creating/9781098105334/).

1. Create the objects from the YAML manifest [setup.yaml](./setup.yaml).
2. Inspect the objects in the namespace `k1` and `k2`.
3. Determine the virtual IP address of Pod `nginx` in namespace `k2`. Try to make a `wget` call on port 80 from the Pod `busybox` in namespace `k1` to the Pod `nginx` in namespace `k2`. The call will fail with the current setup.
4. Create a network policy that allows performing ingress calls for all Pods in namespace `k1` to the Pod `nginx` in namespace `k2`. Pods in all other namespaces should be denied to make ingress calls to Pods in namespace `k2`.
5. Repeat step 3 to verify that a network connection can be established.
---

## Walkthrough


Create the objects from the `setup.yaml` file.

```
$ kubectl apply -f setup.yaml
namespace/k1 created
namespace/k2 created
pod/busybox created
pod/nginx created
networkpolicy.networking.k8s.io/default-deny-ingress created
```

Check on the Pods in namespace `k1` and `k2`.

```
$ kubectl get pod -n k1
NAME      READY   STATUS    RESTARTS   AGE
busybox   1/1     Running   0          3s

$ kubectl get pod -n k2 -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          14s   10.0.0.101   minikube   <none>           <none>
```

Open a connection to the Pod `nginx` won't be allowed and times out.

```
$ kubectl exec -it busybox -n k1 -- wget --timeout=5 10.0.0.101:80
Connecting to 10.0.0.101:80 (10.0.0.101:80)
wget: download timed out
command terminated with exit code 1
```

Define a NetworkPolicy in `allow-ingress-networkpolicy.yaml` that will allow ingress access from the namespace `k1` to `k2`.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-networkpolicy
  namespace: k2
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              role: consumer
      ports:
        - protocol: TCP
          port: 80
```

Create the object from the YAML manifest.

```
$ kubectl apply -f allow-ingress-networkpolicy.yaml
networkpolicy.networking.k8s.io/allow-ingress-networkpolicy created
```

You can now make a call from any Pod in namespace `k1` to the Pod `nginx` in namespace `k2`.

```
$ kubectl exec -it busybox -n k1 -- wget --timeout=5 10.0.0.101:80
Connecting to 10.0.0.101:80 (10.0.0.101:80)
saving to 'index.html'
index.html           100% |********************************|   615  0:00:00 ETA
'index.html' saved
```