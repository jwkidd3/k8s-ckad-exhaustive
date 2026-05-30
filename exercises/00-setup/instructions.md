# Exercise 0 — Cloud9 + kind Cluster Setup

<details>
<summary><b>Quick Reference</b></summary>
<p>

* Environment: AWS Cloud9 (Amazon Linux, x86_64)
* Cluster: 4-node kind cluster (1 control-plane, 3 workers)
* Documentation: [kind quick start](https://kind.sigs.k8s.io/docs/user/quick-start/), [kubectl install](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

</p>
</details>

In this exercise you will prepare your Cloud9 IDE to run a local Kubernetes cluster using [kind](https://kind.sigs.k8s.io/) (Kubernetes IN Docker). Every later exercise in this course assumes the cluster created here is up and reachable.

> **_NOTE:_** Cloud9 instances ship with Docker pre-installed. If you are running outside Cloud9 you will need a working Docker daemon before proceeding.

1. Confirm your Cloud9 instance has Docker running.

    ```
    $ docker info | head -5
    ```

    If Docker is not available, start it with `sudo service docker start`.

2. Install `kubectl`. The version of `kubectl` should be within one minor version of the cluster's Kubernetes version.

    ```
    $ curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    $ sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    $ kubectl version --client
    ```

3. Install `kind` v0.27.0.

    ```
    $ [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
    $ chmod +x ./kind
    $ sudo mv ./kind /usr/local/bin/kind
    $ kind version
    ```

4. From the repository root, inspect the cluster configuration file [`kind-config.yaml`](../../kind-config.yaml). It declares a four-node cluster: one control-plane node and three workers.

5. Create the cluster.

    ```
    $ cd /path/to/k8s-ckad-exhaustive
    $ kind create cluster --config kind-config.yaml
    ```

    The first run will pull the node image and may take a couple of minutes.

6. Verify the cluster is ready and that all four nodes have joined.

    ```
    $ kubectl cluster-info --context kind-cluster
    $ kubectl get nodes
    ```

    You should see four nodes with status `Ready`.

7. Install the metrics server (used later in exercise 18) from the [`components.yaml`](../../components.yaml) file at the repo root.

    ```
    $ kubectl apply -f components.yaml
    $ kubectl -n kube-system rollout status deployment/metrics-server
    ```

8. Confirm metrics collection is working.

    ```
    $ kubectl top nodes
    ```

    It may take a minute after the rollout completes before metrics become available.

When you are done with the course, tear the cluster down with:

```
$ kind delete cluster --name cluster
```
