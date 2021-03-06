# Kubernetes Cluster with Kubenet, RBAC and Container Insights

This example deployes the following components through ARM template:

* Virtual Network
* Log Analytics workspace
* Container Insights
* AKS Cluster with Kubenet, RBAC and AAD integration

Post deployment configurations include:

* Cluster Role bindings for AAD integration
* Helm for RBAC-enabled clusters
* Service Catalog for RBAC-enabled clusters
* OBSA (Open Service Broker for Azure) for RBAC-enabled clusters 

### Caveats

#### #1 - Kubenet

AKS supports two types of Container Networking Interfaces (CNIs):

* Kubenet
* [Azure CNI](../azurecni-rbac)

Kubenet is a very basic, simple network plugin, on Linux only. It does not, of itself, implement more advanced features like cross-node networking or network policy. It is typically used together with a cloud provider that sets up routing rules for communication between nodes, or in single-node environments.

Reference: https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/#kubenet

Waiting for Network Policy implementation such as Calico for AKS.

#### #2 - Billing Tags

The AKS deployment will create a separate resource group to keep the deployed resources such as VMs, NICs, Load Balancers, etc.   This resource will not have any billing tags as defined in the ARM template.  The workaround is to apply these billing tags as a post deployment step.

You can retrieve the resource group that was created as part of the deployment using the following command:

```bash
az aks show --name myAKSCluster --resource-group aks --query nodeResourceGroup
```

#### #3 - Secrets can not be rotated

At this time, the secrets used for Azure AD integration and Service Principal account **can not** be rotated as they are immutable.  *The only way to rotate secrets at this time is through a cluster redeployment.*

#### #4 - Azure AD accounts

Following two limitations exist today:

* Existing non-RBAC enabled AKS clusters cannot currently be updated for RBAC use.
* Guest users in Azure AD, such as if you are using a federated login from a different directory, **are not supported.**

#### #5 - Immutable attributes

While the ARM template can be executed many times, there are some attributes that are immutable.  These are:

* servicePrincipalProfile
* aadProfile
* agentPools



## Prepare environment

#### Create resource group

```bash
az group create --resource-group aks -l eastus
```

#### Create Service Principal for managing Azure resources through the cluster

```bash
az ad sp create-for-rbac --name ss-aks --role Contributor
```
#### Create Server and Client Application Registrations for Azure AD integration

Client app registration is used for interacting through `kubectl`.

```bash
# The Server app registration is a Web app
az ad app create --display-name ss-aad-aks-server --identifier-uris https://ss-aad-aks-server

# The Client app registration is a Native app
az ad app create --display-name ss-aad-aks-client --native-app true
```

#### Update Permissions on the application through Azure Portal

Follow the instructions on 
  https://docs.microsoft.com/en-us/azure/aks/aad-integration


## Deploy Cluster

```bash
az group deployment create -g aks --template-file deploy.json
```


## AAD integration (post deployment)

Add the cluster role bindings such that Kubernetes can authorize users or groups.

Reference: https://docs.microsoft.com/en-us/azure/aks/aad-integration

```bash
# Retrieve the cluster credentials as an admin 
az aks get-credentials --resource-group aks --name myAKSCluster --admin
```
If configuring *individual users*, apply this configuration as a yaml.

```yaml
# Change metadata.name to your own
# Change subjects.name to your own users
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: contoso-cluster-admins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: "senthuran@contoso.com"
```

If configuring *groups*, apply this configuration as a yaml.

```yaml
# Change metadata.name to your own
# Change subjects.name to your own groups
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
 name: contoso-cluster-admins
roleRef:
 apiGroup: rbac.authorization.k8s.io
 kind: ClusterRole
 name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: "894856f1-39f8-4bfe-b16a-510f61af6f41"
```

Once the cluster role bindings are applied, retrieve the cluster credentials as a regular user.

```bash
# Retrieve the cluster credentials
az aks get-credentials --resource-group aks --name myAKSCluster
```
Try to execute any kubectl command and you'll be prompted to login through Azure AD.

### Helm (post deployment)

RBAC-enabled clusters require additional configuration to allow Tiller to deploy resources.

If this step is not complete, then Helm will deploy the following error:

```bash
helm install --name nginx stable/nginx-ingress

Error: release nginx failed: namespaces "default" is forbidden: User "system:serviceaccount:kube-system:default" cannot get namespaces in the namespace "default"
```

#### Create Service Account & Cluster Role Binding
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
```

#### Configure Helm

```bash
helm init --service-account tiller --upgrade
```

### Service Catalog (post deployment)

#### Add Service Catalog Helm repository

```
helm repo add svc-cat https://svc-catalog-charts.storage.googleapis.com
```

#### Deploy Service Catalog with Helm

```
helm install svc-cat/catalog --name catalog --namespace catalog --set controllerManager.healthcheck.enabled=false
```

### OSBA (post deployment)


#### Create a Service Principal

```bash
az ad sp create-for-rbac --name ss-aks-obsa

# output
{
  "appId": "1234567c-3d49-4d0e-ad2d-93d6cfd0cfae",
  "displayName": "ss-aks-obsa",
  "name": "http://ss-aks-obsa",
  "password": "41a0000c-0000-4d0e-0000-93d6cfd0cfae",
  "tenant": "6df988bf-0000-0000-91ab-2d7cd0da2b47"
}
```

#### Get Subscription ID

```bash
az account show --query id --output tsv
```

#### Add OBSA Helm repository

```bash
helm repo add azure https://kubernetescharts.blob.core.windows.net/azure
```

#### Deploy OBSA through Helm

```bash
helm install azure/open-service-broker-azure --name osba --namespace osba \
    --set azure.subscriptionId=a751c1a8-0000-0000-a835-a21e92eda7c4 \
    --set azure.tenantId=72f988bf-86f1-41af-91ab-2d7cd011db47 \
    --set azure.clientId=41a0000c-0000-4d0e-0000-93d6cfd0cfae \
    --set azure.clientSecret=6df988bf-0000-0000-91ab-2d7cd0da2b47
```

## Clean Up

To clean up, simply delete the resource group.

```bash
az group delete -g aks --yes --no-wait
```
