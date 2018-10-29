# Backup MySQL databases using ACI

The purpose of this prototype is to allow MySQL admins to backup databases to Azure Storage for long term retention.  MySQL as a Service on Azure currently supports up to 35 days of backups, but for anything longer, you'll need to backup.  This behaviour may change in the future.

> Please note that this prototype is provided without warantee nor support.

## Steps

1. Create MySQL database
2. Create Storage account, container & generate a SAS token
3. Create Azure Container Registry (ACR)
4. Build Image & Push Image to ACR

```bash
# Build
docker build -t mysqlexport .
# Tag
docker tag -t mysqlexport:latest <your ACR instance>.azurecr.io/mysqlexport:1.0
# Login to your ACR
docker login <your ACR instance>.azurecr.io -u <your username>
```

5. Run the container locally.  Note that you'll need to whitelist your IP address on the MySQL instance.  Fill in the parameters (-e) with the appropriate values from your deployment.

```bash
docker run -e MYSQL_HOST="" -e MYSQL_USER="" -e MYSQL_PASS="" -e MYSQL_BACKUPDBS="" -e MYSQL_BACKUP_FILE="backup.sql" -e AZ_BACKUP_STORAGE_ACCOUNT="" -e AZ_BACKUP_STORAGE_CONTAINER="" -e AZ_BACKUP_STORAGE_SASTOKEN="" -t mysqlexport:latest
```

6. Run the container using ACI.  As of writing this post, ACI in VNETs are only supported in West US, West Central US, North Europe and West Europe.  Therefore, you can't use Service Endpoints in all cases.  If your environment is another region that's not listed above, then you'll need to set 'Allow access to Azure services' to **ON** in MySQL Connection Security.

```bash
# Edit deploy.parameters.json and fill in your environment information.

# Deploy through Azure CLI
az group deployment create --resource-group myResourceGroup --template-file deploy.json --parameters @deploy.parameters.json

# Validate that the backup is created in the storage account

# Delete the ACI instance
az container delete --resource-group myResourceGroup --name mysqlexport -y
```

