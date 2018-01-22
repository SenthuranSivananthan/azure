# Deploy ASP.NET Core 2.0 on Kubernetes

## Create Application & Test Application

### New Application
```bash
dotnet new webapi
```

### Compile & Publish
```bash
dotnet publish
```

### Build Docker Image
```bash
docker build -t dotnetwebapi .
```

### Locally Run Application
```bash
docker run -P dotnetwebapi
docker ps

# Get port number that's mapped to 80
curl http://localhost:32770/api/values

# Expected Value
# ["value1","value2"]
```

### Create ACS with Kubernetes 1.7.9, ACR & Push Image

```bash
# Create Resource Group
az group create -n dotnetcore -l canadacentral

# Create Azure Container Registry
az acr create -n dotnetcoreacr -l eastus -g dotnetcore --sku Standard --admin-enabled

# Create ACS Cluster
az acs create -n ss -g dotnetcore --orchestrator-type Kubernetes --orchestrator-version 1.7.9

# Get ACR Credentials
az acr credential show -n dotnetcoreacr -g dotnetcore

# Login to Docker
docker login dotnetcoreacr.azurecr.io -u dotnetcoreacr

# Tag Docker Image
docker tag dotnetwebapi dotnetcoreacr.azurecr.io/dotnetwebapi

# Push to ACR
docker push dotnetcoreacr.azurecr.io/dotnetwebapi
```

### Connect to Kubernetes & Deploy Image

```bash
az acs kubernetes get-credentials -n ss -g dotnetcore

# Validate connectivity
kubectl get nodes

# Create secret to allow Kubernetes to download images from ACR
kubectl create secret docker-registry acr --docker-server=dotnetcoreacr.azurecr.io --docker-username=dotnetcoreacr --docker-password=<ENTER_PASSWORD> --docker-email=Senthuran.Sivananthan@microsoft.com 

# Deploy YAML
kubectl apply -f kubernetes.yaml

# Monitor the deployment and wait for public IP to be provided for the service
watch -n 1 kubectl get all
```

### Test
```bash

# Replace 52.228.47.228 with your own IP that was assigned to the service
curl http://52.228.47.228/api/values
```