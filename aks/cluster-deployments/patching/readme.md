# Security Patching AKS Clusters

This exmaple walks through the process for setting up automatic patching and node reboots.

## Are security updates applied to AKS agent nodes?

Reference: https://docs.microsoft.com/en-us/azure/aks/faq

Yes, Azure automatically applies security patches to the nodes in your cluster on a nightly schedule. However, you are responsible for ensuring that nodes are rebooted as required. You have several options for performing node reboots:

* Manually, through the Azure portal or the Azure CLI.
* By upgrading your AKS cluster. Cluster upgrades automatically [cordon and drain nodes](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/), then bring each node back up with the latest Ubuntu image and a new patch version or a minor Kubernetes version. For more information, see Upgrade an AKS cluster.
* Using [Kured](https://github.com/weaveworks/kured), an open-source reboot daemon for Kubernetes. Kured runs as a DaemonSet and monitors each node for the presence of a file indicating that a reboot is required. OS reboots are managed across the cluster using the same cordon and drain process as a cluster upgrade.

## What happens during the patch process?

1.  AKS applies security patches on a nightly basis on each node.

2.  Node creates file /var/run/reboot-required

3.  kured checks periodically for the file `/var/run/reboot-required`

4.  If kured finds this file, then it acquires a lock, then
    - node is cordoned
    - scheduling is disabled
    - pods are drained

5.  Node is rebooted

6.  Once the node reboots, then
    - node is uncordoned
    - schedulign is enabled

7.  Next node is checked and process repeated

## Steps

> The deployment in this example is based on Azure CNI.  Please review [Azure CNI + RBAC deployment](../azurecni-rbac) for more information.

#### Configure ClusterRole and ClusterRoleBinding

```bash
kubectl apply -f https://raw.githubusercontent.com/weaveworks/kured/master/kured-rbac.yaml
```

#### Create a YAML

> Note: This yaml is using the latest build version.  I've also set the period as 2 minutes so that you can see behvaiour sooner.  Please change based on your need.

```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kured
  namespace: kube-system
---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: kured            # Must match `--ds-name`
  namespace: kube-system # Must match `--ds-namespace`
spec:
  template:
    metadata:
      labels:
        name: kured
    spec:
      serviceAccountName: kured
      containers:
        - name: kured
          image: quay.io/weaveworks/kured:master-549be77
          imagePullPolicy: IfNotPresent
          command:
            - /usr/bin/kured
          args:
#            - --alert-filter-regexp=^RebootRequired$
#            - --ds-name=kured
#            - --ds-namespace=kube-system
#            - --lock-annotation=weave.works/kured-node-lock
            - --period=2m
#            - --prometheus-url=http://prometheus.monitoring.svc.cluster.local
#            - --reboot-sentinel=/var/run/reboot-required
#            - --slack-hook-url=https://hooks.slack.com/...
#            - --slack-username=prod
#
# NO USER SERVICEABLE PARTS BEYOND THIS POINT
          env:
            # Pass in the name of the node on which this pod is scheduled
            # for use with drain/uncordon operations and lock acquisition
            - name: KURED_NODE_ID
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
          volumeMounts:
            # Needed for two purposes:
            # * Testing for the existence of /var/run/reboot-required
            # * Accessing /var/run/dbus/system_bus_socket to effect reboot
            - name: hostrun
              mountPath: /var/run
      restartPolicy: Always
      volumes:
        - name: hostrun
          hostPath:
            path: /var/run
```

#### Apply the YAML

```bash
kubectl apply -f kured-ds.yaml
```

### Test

```bash
ssh user@node
sudo touch /var/run/reboot-required
```

#### Monitor the kured pod logs

```bash
# Get the pod name
kubectl get all -n kube-system

# Change the pod name to your own
watch -n 1 kubectl logs POD_NAME -n kube-system
```

#### Monitor Kubernetes Nodes

```bash
watch -n 1 kubectl get nodes
```

#### Example kured logs

```bash
time="2018-09-26T11:22:07Z" level=info msg="Kubernetes Reboot Daemon: master-549be77"
time="2018-09-26T11:22:07Z" level=info msg="Node ID: aks-generalpool-15365993-0"
time="2018-09-26T11:22:07Z" level=info msg="Lock Annotation: kube-system/kured:weave.works/kured-node-lock"
time="2018-09-26T11:22:07Z" level=info msg="Reboot Sentinel: /var/run/reboot-required every 2m0s"
time="2018-09-26T11:24:11Z" level=info msg="Reboot required"
time="2018-09-26T11:24:11Z" level=warning msg="Lock already held: aks-generalpool-15365993-1"
time="2018-09-26T11:26:11Z" level=info msg="Reboot required"
time="2018-09-26T11:26:11Z" level=warning msg="Lock already held: aks-generalpool-15365993-1"
time="2018-09-26T11:28:11Z" level=info msg="Reboot required"
time="2018-09-26T11:28:11Z" level=info msg="Acquired reboot lock"
time="2018-09-26T11:28:11Z" level=info msg="Draining node aks-generalpool-15365993-0"
time="2018-09-26T11:28:13Z" level=info msg="node \"aks-generalpool-15365993-0\" cordoned" cmd=/usr/bin/kubectl std=out
time="2018-09-26T11:28:14Z" level=warning msg="WARNING: Ignoring DaemonSet-managed pods: azure-cni-networkmonitor-r89fh, kube-proxy-zcg2z, kube-svc-redirect-7b4vp, kured-g65pc, omsagent-nj5c5" cmd=/usr/bin/kubectl std=err
time="2018-09-26T11:28:23Z" level=info msg="pod \"kubernetes-dashboard-7979b9b5f4-wgcvp\" evicted" cmd=/usr/bin/kubectl std=out
time="2018-09-26T11:28:24Z" level=info msg="pod \"metrics-server-789c47657d-j6x94\" evicted" cmd=/usr/bin/kubectl std=out
time="2018-09-26T11:28:24Z" level=info msg="pod \"frontend-cb8f9758-8cgtk\" evicted" cmd=/usr/bin/kubectl std=out
time="2018-09-26T11:28:25Z" level=info msg="pod \"heapster-d6489f7fd-wmxv9\" evicted" cmd=/usr/bin/kubectl std=out
time="2018-09-26T11:28:26Z" level=info msg="pod \"backend-6cb55cd647-fjts8\" evicted" cmd=/usr/bin/kubectl std=out
time="2018-09-26T11:28:27Z" level=info msg="pod \"frontend-cb8f9758-z6l7v\" evicted" cmd=/usr/bin/kubectl std=out
time="2018-09-26T11:28:28Z" level=info msg="pod \"omsagent-rs-cd4dd4dbc-8skfl\" evicted" cmd=/usr/bin/kubectl std=out
time="2018-09-26T11:28:28Z" level=info msg="pod \"backend-6cb55cd647-ff5mn\" evicted" cmd=/usr/bin/kubectl std=out


< Node rebooted >

time="2018-09-26T11:31:17Z" level=info msg="Kubernetes Reboot Daemon: master-549be77"
time="2018-09-26T11:31:17Z" level=info msg="Node ID: aks-generalpool-15365993-0"
time="2018-09-26T11:31:17Z" level=info msg="Lock Annotation: kube-system/kured:weave.works/kured-node-lock"
time="2018-09-26T11:31:17Z" level=info msg="Reboot Sentinel: /var/run/reboot-required every 2m0s"
time="2018-09-26T11:31:17Z" level=info msg="Holding lock"
time="2018-09-26T11:31:17Z" level=info msg="Uncordoning node aks-generalpool-15365993-0"
time="2018-09-26T11:31:19Z" level=info msg="node \"aks-generalpool-15365993-0\" uncordoned" cmd=/usr/bin/kubectl std=out
time="2018-09-26T11:31:19Z" level=info msg="Releasing lock"
```


## Clean Up

To clean up, simply delete the resource group.

```bash
az group delete -g aks --yes --no-wait
```
