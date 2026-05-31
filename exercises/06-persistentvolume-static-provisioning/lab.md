# Lab 6


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `default`<br>
* Documentation: [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

</p>
</details>

In this exercise, you will create a PersistentVolume, connect it to a PersistentVolumeClaim and mount the claim to a specific path of a Pod.

> **_NOTE:_** If you do not already have a cluster, you can create one by using minikube or you can use the Katacoda lab ["Creating a Pod with Volume of type PersistentVolume with static binding"](https://learning.oreilly.com/scenarios/ckad-volumes-creating/9781098105365/).

1. Create a PersistentVolume named `pv`, access mode `ReadWriteMany`, 512Mi of storage capacity and the host path `/data/config`.
2. Create a PersistentVolumeClaim named `pvc`. The claim should request 256Mi and use an empty string value for the storage class. Ensure that the PersistentVolumeClaim is properly bound after its creation.
3. Mount the PersistentVolumeClaim from a new Pod named `app` with the path `/var/app/config`. The Pod uses the image `nginx:1.21.6`.
4. Open an interactive shell to the Pod and create an empty file named `test.txt` in the directory `/var/app/config`. Confirm with `ls -l` that the file exists.

---

## Walkthrough


Create a manifest for the PersistentVolume and store it in the file `pv.yaml`.

```yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv
spec:
  capacity:
    storage: 512Mi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: /data/config
```

Create the PersistentVolume with the following command.

```
$ kubectl apply -f pv.yaml
persistentvolume/pv created
$ kubectl get pv
NAME   CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
pv     512Mi      RWX            Retain           Available                                   12s
```

Create a manifest for the PersistentVolumeClaim and store it in the file `pvc.yaml`.

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: ""
  resources:
    requests:
      storage: 256Mi
```

Create the PersistentVolumeClaim with the following command. You will see that the PersistentVolumeClaim has a status of "Bound".

```
$ kubectl apply -f pvc.yaml
persistentvolumeclaim/pvc created
$ kubectl get pvc
NAME   STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
pvc    Bound    pv       512Mi      RWX                           2s
```

Create a manifest for the Pod and store it in the file `pod.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
  - image: nginx:1.21.6
    name: app
    volumeMounts:
    - mountPath: "/var/app/config"
      name: configpvc
  volumes:
  - name: configpvc
    persistentVolumeClaim:
      claimName: pvc
  restartPolicy: Never
```

Create the Pod object from the YAML manifest file.

```
$ kubectl apply -f pod.yaml
pod/app created
```

Shell into the Pod and create a file in the mounted directory.

```
$ kubectl exec app -it -- /bin/sh
# cd /var/app/config
# ls -l
total 0
# touch test.txt
# ls -l
total 0
-rw-r--r-- 1 root root 0 Dec 30 17:24 test.txt
```
