# Upgrade AKS Clusters using ARM

This exmaple walks through the AKS upgrade process and the method for upgrading through ARM templates.

Please remember that AKS will allow 1 minor version upgrade per execution.  This means that you can not upgrade from 1.9.9 to 1.11.2.  Instead, you will need to first upgrade 1.9.9 to 1.10.x, then upgrade from 1.10.x to 1.11.2.

## What happens during an upgrade process?

Follow steps are taken by AKS to upgrade your cluster nodes:

1. Master nodes are upgraded.

2. A new node is created with the target Kubernetes version and added to the cluster.  A node is added so that the cluster will not lose the compute capacity during the upgrade process.

3. A node is selected from the node pool
    - Scheduling is disabled [  **Status: SchedulingDisabled** ]
    - Containers are drained and rescheduled.   [ **Status: NotReady** ]
    - Node is deleted

4. New node is created with the same node name and target Kubernetes version.

5. Steps 3 and 4 are repeated for every node except the last node.

6. Last node follows step 3 only.


## Steps to upgrade

### Lookup the available upgrades

```yaml
# Get the name of the AKS cluster
az aks list --resource-group aks -o table

# Retrieve the available upgrade options
az aks get-upgrades -o table --resource-group [aks-resource-group] --name [aks-cluster-name]
```

### Deploy Cluster with version 1.9.9

```bash
# Create resource group
az group create --resource-group aks -l eastus

# Deploy ARM template and fill in all of the prompts
az group deployment create -g aks --template-file deploy.json
```

Output

```
Name     ResourceGroup    MasterVersion    NodePoolVersion    Upgrades
-------  ---------------  ---------------  -----------------  --------------------------------------
default  aks             1.9.9            1.9.9              1.9.10, 1.10.3, 1.10.5, 1.10.6, 1.10.7
```


### Upgrade Cluster to 1.11.2

```bash
# Get the name of the AKS cluster
az aks list --resource-group aks -o table
```

For the prompt, enter:

* Name:  *Cluster name from above*
* Kubernetes Vesrion: 1.11.2

```yaml
# Deploy ARM template to upgrade
az group deployment create -g aks --template-file upgrade.json
```

Since the attempt is to upgrade from 1.9.9 to 1.11.2, the upgrade will fail with the following error:

```
Deployment failed. Correlation ID: 1fc57954-5a72-44b6-b9a3-a79311598365. {
  "code": "OperationNotAllowed",
  "message": "Upgrading Kubernetes version 1.9.9 to 1.11.2 is not allowed. Only one minor version upgrade is supported."
}
```

### Upgrade 1 minor version at a time

```bash
# Get the name of the AKS cluster
az aks list --resource-group aks -o table
```

For the prompt, enter:

* Name:  *Cluster name from above*
* Kubernetes Vesrion: 1.10.7

```yaml
# Deploy ARM template to upgrade
az group deployment create -g aks --template-file upgrade.json
```

Repeat until you reach the target Kubernetes version.

## Clean Up

To clean up, simply delete the resource group.

```bash
az group delete -g aks --yes --no-wait
```
