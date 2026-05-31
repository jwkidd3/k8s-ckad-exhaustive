# Lab 8


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `default`<br>
* Documentation: [Pods](https://kubernetes.io/docs/concepts/workloads/pods/), [Volumes](https://kubernetes.io/docs/concepts/storage/volumes/)

</p>
</details>

The adapter pattern helps with providing a simplified, homogenized view of an application running within a container. For example, we could stand up another container that unifies the log output of the application container. As a result, other monitoring tools can rely on a standardized view of the log output without having to transform it into an expected format.

> **_NOTE:_** If you do not already have a cluster, you can create one by using minikube or you can use the Katacoda lab ["Creating a sidecar container"](https://learning.oreilly.com/scenarios/ckad-multi-container-creating/9781098104993/).

1. Create a new Pod in a YAML file named `adapter.yaml`. The Pod declares two containers. The container `app` uses the image `busybox` and runs the command `while true; do echo "$(date) | $(du -sh ~)" >> /var/logs/diskspace.txt; sleep 5; done;`. The adapter container `transformer` uses the image `busybox` and runs the command `sleep 20; while true; do while read LINE; do echo "$LINE" | cut -f2 -d"|" >> $(date +%Y-%m-%d-%H-%M-%S)-transformed.txt; done < /var/logs/diskspace.txt; sleep 20; done;` to strip the log output off the date for later consumption by a monitoring tool. Be aware that the logic does not handle corner cases (e.g. automatically deleting old entries) and would look different in production systems.
2. Before creating the Pod, define an `emptyDir` volume. Mount the volume in both containers with the path `/var/logs`.
3. Create the Pod, log into the container `transformer`. The current directory should continuously write a new file every 20 seconds.

---

## Walkthrough


You can create the initial Pod setup with the following command.

```
$ kubectl run adapter --image=busybox -o yaml --dry-run=client --restart=Never -- /bin/sh -c 'while true; do echo "$(date) | $(du -sh ~)" >> /var/logs/diskspace.txt; sleep 5; done;' > adapter.yaml
```
The final Pod YAML file should look something like this:

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  name: adapter
spec:
  volumes:
    - name: config-volume
      emptyDir: {}
  containers:
  - args:
    - /bin/sh
    - -c
    - 'while true; do echo "$(date) | $(du -sh ~)" >> /var/logs/diskspace.txt; sleep 5; done;'
    image: busybox
    name: app
    volumeMounts:
      - name: config-volume
        mountPath: /var/logs
    resources: {}
  - image: busybox
    name: transformer
    args:
    - /bin/sh
    - -c
    - 'sleep 20; while true; do while read LINE; do echo "$LINE" | cut -f2 -d"|" >> $(date +%Y-%m-%d-%H-%M-%S)-transformed.txt; done < /var/logs/diskspace.txt; sleep 20; done;'
    volumeMounts:
      - name: config-volume
        mountPath: /var/logs
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
```
You should find that a new text file in the current directory every 20 seconds. Each of the files contain the disk space without the date prefix.

```
$ kubectl apply -f adapter.yaml
$ kubectl exec adapter --container=transformer -it -- /bin/sh
# cat /var/logs/diskspace.txt
Tue Nov 12 15:13:48 UTC 2019 | 4.0K	/root
Tue Nov 12 15:13:53 UTC 2019 | 4.0K	/root
Tue Nov 12 15:13:58 UTC 2019 | 4.0K	/root
Tue Nov 12 15:14:03 UTC 2019 | 4.0K	/root
# ls -l
-rw-r--r--    1 root     root            60 Nov 12 15:14 2019-11-12-15-14-10-transformed.txt
-rw-r--r--    1 root     root           108 Nov 12 15:14 2019-11-12-15-14-30-transformed.txt
...
# cat 2019-11-12-15-14-10-transformed.txt
 4.0K	/root
 4.0K	/root
 4.0K	/root
 4.0K	/root
 4.0K	/root
# exit
```
