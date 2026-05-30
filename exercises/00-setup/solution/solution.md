# Solution

Verify Docker is running on your Cloud9 instance.

```
$ docker info | head -5
Client: Docker Engine - Community
 Version:    24.0.7
 Context:    default
 Debug Mode: false
 Plugins:
```

Install `kubectl`.

```
$ curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
$ sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
$ kubectl version --client
Client Version: v1.31.0
Kustomize Version: v5.4.2
```

Install `kind`.

```
$ curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
$ chmod +x ./kind
$ sudo mv ./kind /usr/local/bin/kind
$ kind version
kind v0.27.0 go1.22.7 linux/amd64
```

Create the cluster from the root `kind-config.yaml`.

```
$ kind create cluster --config kind-config.yaml
Creating cluster "cluster" ...
 ✓ Ensuring node image (kindest/node:v1.32.0) 🖼
 ✓ Preparing nodes 📦 📦 📦 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
 ✓ Joining worker nodes 🚜
Set kubectl context to "kind-cluster"
You can now use your cluster with:

kubectl cluster-info --context kind-cluster
```

Verify the four nodes are `Ready`.

```
$ kubectl get nodes
NAME                    STATUS   ROLES           AGE   VERSION
cluster-control-plane   Ready    control-plane   90s   v1.32.0
cluster-worker          Ready    <none>          75s   v1.32.0
cluster-worker2         Ready    <none>          75s   v1.32.0
cluster-worker3         Ready    <none>          75s   v1.32.0
```

Install the metrics server and wait for it to be ready.

```
$ kubectl apply -f components.yaml
serviceaccount/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
service/metrics-server created
deployment.apps/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created

$ kubectl -n kube-system rollout status deployment/metrics-server
deployment "metrics-server" successfully rolled out
```

After roughly a minute, node metrics become available.

```
$ kubectl top nodes
NAME                    CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
cluster-control-plane   145m         3%     680Mi           8%
cluster-worker          22m          0%     180Mi           2%
cluster-worker2         18m          0%     175Mi           2%
cluster-worker3         20m          0%     179Mi           2%
```

Your cluster is now ready for the remainder of the course.
