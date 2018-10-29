# Backup MySQL databases using ACI

The purpose of this prototype is to allow MySQL admins to backup databases to Azure Storage for long term retention.  MySQL as a Service on Azure currently supports up to [35 days of backups](https://docs.microsoft.com/en-us/azure/mysql/concepts-backup), but for anything longer, you'll need to backup.  This behaviour may change in the future.

## Disclaimer

Please note that this prototype is provided as-is and without warrantee nor support.

## Prerequisites

1. Create MySQL database
2. Create Storage account, container & generate a SAS token
3. Create Azure Container Registry (ACR)
4. Docker on your computer

## Build Image & Push Image to ACR

```bash
# Build
docker build -t mysqlexport .

# Tag
docker tag -t mysqlexport:latest <your ACR instance>.azurecr.io/mysqlexport:1.0

# Login to your ACR
docker login <your ACR instance>.azurecr.io -u <your username>

# Push image
docker push <your ACR instance>.azurecr.io/mysqlexport:1.0
```

## Run the container locally

Fill in the parameters (-e) with the appropriate values from your deployment.

Note that you'll need to [whitelist your IP address](https://docs.microsoft.com/en-us/azure/mysql/howto-manage-firewall-using-portal) on the MySQL instance.

![Whitelist IP](https://docs.microsoft.com/en-us/azure/mysql/media/howto-manage-firewall-using-portal/2-add-my-ip.png)

```bash
docker run -e MYSQL_HOST="" -e MYSQL_USER="" -e MYSQL_PASS="" -e MYSQL_BACKUPDBS="" -e MYSQL_BACKUP_FILE="backup.sql" -e AZ_BACKUP_STORAGE_ACCOUNT="" -e AZ_BACKUP_STORAGE_CONTAINER="" -e AZ_BACKUP_STORAGE_SASTOKEN="" -t mysqlexport:latest
```

## Run the container using ACI

As of writing this post, ACI in VNETs are only supported in West US, West Central US, North Europe and West Europe.

Therefore, you can't use Service Endpoints in all cases.  If your environment is another region that's not listed above, then you'll need to set ['Allow access to Azure services'](https://docs.microsoft.com/en-us/azure/mysql/concepts-firewall-rules) to **ON** in MySQL Connection Security.

![Access settings](https://docs.microsoft.com/en-us/azure/mysql/media/concepts-firewall-rules/allow-azure-services.png)

```bash
# Edit deploy.parameters.json and fill in your environment information.

# Deploy through Azure CLI
az group deployment create --resource-group myResourceGroup --template-file deploy.json --parameters @deploy.parameters.json
```

## Validate

Validate that the backup is created in the storage account by navigating to the storage account using Azure Portal or [Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/).

## Clean Up

```bash
# Delete the ACI instance
az container delete --resource-group myResourceGroup --name mysqlexport -y
```

