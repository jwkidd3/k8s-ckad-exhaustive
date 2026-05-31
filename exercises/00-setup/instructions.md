# Exercise 0 — Cloud9 + kind Cluster Setup

<details>
<summary><b>Quick Reference</b></summary>
<p>

* Environment: AWS Cloud9 in `us-east-1` (Amazon Linux 2023, m5.large)
* Cluster: 4-node kind cluster (1 control-plane, 3 workers)
* Documentation: [AWS Cloud9](https://docs.aws.amazon.com/cloud9/), [kind quick start](https://kind.sigs.k8s.io/docs/user/quick-start/)

</p>
</details>

In this exercise you will provision an AWS Cloud9 IDE, expand its root EBS volume, clone the course repository, and stand up the 4-node kind cluster that every subsequent lab depends on.

## Part A — Create the Cloud9 Environment

1. Sign in to the AWS Console and switch the region selector to **US East (N. Virginia) — `us-east-1`**.

2. Open the Cloud9 service and choose **Create environment**.

3. Configure the environment as follows:

    - **Name:** your login name (for example `jsmith`)
    - **Environment type:** *Create a new EC2 instance for environment (direct access)*
    - **Instance type:** **m5.large**
    - **Platform:** **Amazon Linux 2023**
    - **Connection:** **Secure Shell (SSH)**
    - Leave every other field at its default.

4. Click **Create** and wait ~3 minutes for the environment to finish provisioning.

5. Open the new environment from the Cloud9 dashboard. You should land in a browser IDE with a terminal pane at the bottom.

## Part B — Clone the Repo and Resize the Disk

The default Cloud9 EBS root volume is 10 GB, which fills up quickly once Docker pulls the kind node image. Expand it to 100 GB before installing anything.

6. In the Cloud9 terminal, clone this repository:

    ```
    $ cd ~/environment
    $ git clone https://github.com/jwkidd3/k8s-ckad-exhaustive.git
    $ cd k8s-ckad-exhaustive
    ```

7. Run the setup script from this lab directory:

    ```
    $ bash exercises/00-setup/setup.sh
    ```

   The script calls `ec2 modify-volume` to grow the instance's root volume to 100 GB and waits for the modification to begin optimizing.

8. When the script tells you to, reboot the instance to apply the resize:

    ```
    $ sudo reboot
    ```

   Your Cloud9 terminal will disconnect for ~1 minute. Reopen the environment when it returns. Cloud-init will grow the partition and XFS filesystem on boot.

9. Confirm the new size:

    ```
    $ df -h /
    Filesystem      Size  Used Avail Use% Mounted on
    /dev/nvme0n1p1  100G  3.0G   97G   3% /
    ```

## Part C — Install kubectl and kind

10. Confirm Docker is up (it ships installed and enabled on Cloud9):

    ```
    $ docker info | head -5
    ```

11. Install `kubectl`:

    ```
    $ curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    $ sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    $ kubectl version --client
    ```

12. Install `kind` v0.27.0:

    ```
    $ [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
    $ chmod +x ./kind
    $ sudo mv ./kind /usr/local/bin/kind
    $ kind version
    ```

## Part D — Create the kind Cluster

13. From the repo root, inspect [`kind-config.yaml`](../../kind-config.yaml). It declares one control-plane node and three workers.

14. Create the cluster:

    ```
    $ cd ~/environment/k8s-ckad-exhaustive
    $ kind create cluster --config kind-config.yaml
    ```

    The first run pulls the node image and takes a couple of minutes.

15. Verify all four nodes have joined and show `Ready`:

    ```
    $ kubectl cluster-info --context kind-cluster
    $ kubectl get nodes
    ```

16. Install the metrics-server from [`components.yaml`](../../components.yaml) (used later in exercise 18):

    ```
    $ kubectl apply -f components.yaml
    $ kubectl -n kube-system rollout status deployment/metrics-server
    ```

17. After about a minute, confirm metrics collection is working:

    ```
    $ kubectl top nodes
    ```

When you finish the course, tear the cluster down with:

```
$ kind delete cluster --name cluster
```
