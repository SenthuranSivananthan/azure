# Deploy Container Insights to AKS cluster

This example will provide 2 scenarios:

* Deploying Container Insights for new clusters
* Enabling Container Insights for existing clusters

## New cluster

> The deployment in this example is based on Azure CNI.  Please review [Azure CNI + RBAC deployment](../azurecni-rbac) for more information.

```bash
# Create a new resource group
az group create --resource-group aks -l eastus

# Deploy cluster with Container Insights
az group deployment create -g aks --template-file new-cluster.json
```

## Existing Cluster

This deployment will install the Container Insights solution to Log Analytics and integrate the AKS cluster to Log Analytics workspace.

```bash
# Find the id & location of the Log Analytics workspace
az resource list --resource-group aks --resource-type "Microsoft.OperationalInsights/workspaces"

# Deploy the template and fill in the prompts
az group deployment create -g aks --template-file existing-cluster.json
```

## Clean Up

To clean up, simply delete the resource group.

```bash
az group delete -g aks --yes --no-wait
```
