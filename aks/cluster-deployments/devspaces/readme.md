# Enable Kubernetes environments for developers using Dev Spaces

This exmaple walks through the steps for enabling Dev Spaces in AKS.

Azure Dev Spaces provides a rapid, iterative Kubernetes development experience for teams. With minimal dev machine setup, you can iteratively run and debug containers directly in Azure Kubernetes Service (AKS). Develop on Windows, Mac, or Linux using familiar tools like Visual Studio, Visual Studio Code, or the command line.

More information: https://docs.microsoft.com/en-us/azure/dev-spaces/azure-dev-spaces

## Steps

> The deployment in this example is based on Azure CNI.  Please review [Azure CNI + RBAC deployment](../azurecni-rbac) for more information.

#### Get the name of the AKS cluster

```bash
az aks list --resource-group aks -o table
```

#### Enable HTTP Application Routing

Enabling HTTP Application Routing will create a DNS zone as **[guid].[region].aksapp.io**, for example: `2b282ad0cac343c28944.canadacentral.aksapp.io`

This DNS zone is deployed to the node resource group (i.e. **MC_** resource group associated to the cluster).

```bash
az group deployment create -g aks --template-file httpapprouting.json
```

You **cannot** customize the DNS zone.

You can view the DNS zone using:

```bash
az aks show --resource-group myResourceGroup --name myAKSCluster --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName
```

#### Test HTTP Application Routing

Follow the instructions on https://docs.microsoft.com/en-us/azure/aks/http-application-routing#use-http-routing to test your deployment.

#### Enable Dev Spaces

**Note:**  *--update* switch is optional.  This switch will install or update the local client components (i.e. azds) and can take some time depending on the packages that needs to be downloaded.

```
az aks use-dev-spaces --resource-group myResourceGroup --name myAKSCluster --update
```

#### Start debugging your application

Language specific guides are published at https://docs.microsoft.com/en-us/azure/dev-spaces/azure-dev-spaces#get-started-on-azure-dev-spaces

## Clean Up

To clean up, simply delete the resource group.

```bash
az group delete -g aks --yes --no-wait
```
