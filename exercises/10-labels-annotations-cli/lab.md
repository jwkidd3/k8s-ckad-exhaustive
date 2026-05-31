# Lab 10


<details>
<summary><b>Quick Reference</b></summary>
<p>

* Namespace: `default`<br>
* Documentation: [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/), [Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)

</p>
</details>

In this exercise, you will exercise assigning labels and annotations to a set of Pods. Moreover, you will use `kubectl` to query for Pods based on different requirements.

> **_NOTE:_** If you do not already have a cluster, you can create one by using minikube or you can use the Katacoda labs ["Assigning labels to Pods imperatively"](https://learning.oreilly.com/scenarios/ckad-labels-assigning/9781098105181/) and ["Assigning annotations to Pods imperatively"](https://learning.oreilly.com/scenarios/ckad-annotations-assigning/9781098105204/).

1. Create three different Pods with the names `frontend`, `backend` and `database` that use the image `nginx:1.23.4`. For convenience, you can use the file [`pods.yaml`](./pods.yaml) to create the Pods.
2. Declare labels for those Pods as follows:

- `frontend`: `env=prod`, `team=shiny`
- `backend`: `env=prod`, `team=legacy`, `app=v1.2.4`
- `database`: `env=prod`, `team=storage`

3. Declare annotations for those Pods as follows:

- `frontend`: `contact=John Doe`, `commit=2d3mg3`
- `backend`: `contact=Mary Harris`

4. Render the list of all Pods and their labels.
5. Use label selectors on the command line to query for all production Pods that belong to the teams `shiny` and `legacy`.
6. Remove the label `env` from the `backend` Pod and rerun the selection.
7. Render the surrounding 3 lines of YAML of all Pods that have annotations.

---

## Walkthrough


You can assign labels upon Pod creation with the `--labels` option.

```
$ kubectl run frontend --image=nginx --restart=Never --labels=env=prod,team=shiny
pod/frontend created
$ kubectl run backend --image=nginx --restart=Never --labels=env=prod,team=legacy,app=v1.2.4
pod/backend created
$ kubectl run database --image=nginx --restart=Never --labels=env=prod,team=storage
pod/database created
```

Edit the existing Pods with the `edit` command and add the annotations as follows:

```
$ kubectl edit pod frontend
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    commit: 2d3mg3
    contact: John Doe
  name: frontend
...
```

```
$ kubectl edit pod backend
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    contact: 'Mary Harris'
  name: backend
...
```

Render all Pods and their Pods including their assigned labels.

```
$ kubectl get pods --show-labels
NAME       READY   STATUS    RESTARTS   AGE   LABELS
backend    1/1     Running   0          41s   app=v1.2.4,env=prod,team=legacy
database   1/1     Running   0          8s    env=prod,team=storage
frontend   1/1     Running   0          1m    env=prod,team=shiny
```

You can combine the selector rules into one expression.

```
$ kubectl get pods -l 'team in (shiny, legacy)',env=prod --show-labels
NAME       READY   STATUS    RESTARTS   AGE   LABELS
backend    1/1     Running   0          19m   app=v1.2.4,env=prod,team=legacy
frontend   1/1     Running   0          20m   env=prod,team=shiny
```

You can add and remove labels with the `label` command. The selection now doesn't match for the `backend` Pod anymore.

```
$ kubectl label pod backend env-
pod/backend labeled
$ kubectl get pods -l 'team in (shiny, legacy)',env=prod --show-labels
NAME       READY   STATUS    RESTARTS   AGE   LABELS
frontend   1/1     Running   0          23m   env=prod,team=shiny
```

The `grep` command can help with rendering any YAML code around the identified search term.

```
$ kubectl get pods -o yaml | grep -C 3 'annotations:'
- apiVersion: v1
  kind: Pod
  metadata:
    annotations:
      cni.projectcalico.org/podIP: 192.168.60.163/32
      contact: Mary Harris
    creationTimestamp: 2019-05-10T17:57:38Z
--
--
- apiVersion: v1
  kind: Pod
  metadata:
    annotations:
      cni.projectcalico.org/podIP: 192.168.60.147/32
    creationTimestamp: 2019-05-10T17:58:11Z
    labels:
--
--
- apiVersion: v1
  kind: Pod
  metadata:
    annotations:
      cni.projectcalico.org/podIP: 192.168.60.159/32
      commit: 2d3mg3
      contact: John Doe
```
