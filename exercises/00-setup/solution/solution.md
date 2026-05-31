# Solution

## Part A — Create the Cloud9 Environment

This is point-and-click in the AWS console. The selections to make are:

| Field | Value |
|---|---|
| Region | US East (N. Virginia) — `us-east-1` |
| Name | your login name |
| Environment type | Create a new EC2 instance for environment (direct access) |
| Instance type | m5.large |
| Platform | Amazon Linux 2023 |
| Connection | Secure Shell (SSH) |
| Everything else | accept defaults |

When the environment opens you'll see a terminal pane like:

```
ec2-user@ip-172-31-XX-XX:~/environment $
```

## Part B — Clone the Repo and Resize the Disk

```
$ cd ~/environment
$ git clone https://github.com/jwkidd3/k8s-ckad-exhaustive.git
Cloning into 'k8s-ckad-exhaustive'...
$ cd k8s-ckad-exhaustive
$ bash exercises/00-setup/setup.sh
==> Fetching instance metadata (IMDSv2)...
    instance:  i-0abcd1234ef567890
    region:    us-east-1
==> Locating root EBS volume...
    volume:    vol-0a1b2c3d4e5f67890 (currently 10 GB)
==> Modifying volume to 100 GB...
==> Waiting for volume modification to enter 'optimizing'...
    state: modifying
    state: modifying
    state: optimizing

================================================================
Volume vol-0a1b2c3d4e5f67890 is now 100 GB at the EBS layer.

To pick up the new size at the OS layer, reboot the instance:

    sudo reboot

Cloud-init will grow the partition and XFS filesystem on boot.
After the instance comes back, reconnect to the Cloud9 IDE and
verify with:

    df -h /
================================================================
```

```
$ sudo reboot
```

After the IDE reconnects:

```
$ df -h /
Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme0n1p1  100G  3.0G   97G   3% /
```

## Part C — Install kubectl and kind

```
$ docker info | head -5
Client: Docker Engine - Community
 Version:    24.0.7
 Context:    default
 Debug Mode: false
 Plugins:

$ curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
$ sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
$ kubectl version --client
Client Version: v1.31.0
Kustomize Version: v5.4.2

$ curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
$ chmod +x ./kind
$ sudo mv ./kind /usr/local/bin/kind
$ kind version
kind v0.27.0 go1.22.7 linux/amd64
```

## Part D — Create the kind Cluster

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

$ kubectl get nodes
NAME                    STATUS   ROLES           AGE   VERSION
cluster-control-plane   Ready    control-plane   90s   v1.32.0
cluster-worker          Ready    <none>          75s   v1.32.0
cluster-worker2         Ready    <none>          75s   v1.32.0
cluster-worker3         Ready    <none>          75s   v1.32.0

$ kubectl apply -f components.yaml
serviceaccount/metrics-server created
...
deployment.apps/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created

$ kubectl -n kube-system rollout status deployment/metrics-server
deployment "metrics-server" successfully rolled out

$ kubectl top nodes
NAME                    CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
cluster-control-plane   145m         3%     680Mi           8%
cluster-worker          22m          0%     180Mi           2%
cluster-worker2         18m          0%     175Mi           2%
cluster-worker3         20m          0%     179Mi           2%
```

Your cluster is now ready for the remainder of the course.
