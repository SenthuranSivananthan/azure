### Display the last time in json

```bash
az storage account show -n senthurantestdrsource -g test-stg-dr --expand geoReplicationStats
```

### Display the last time in a table
```bash
az storage account show -n senthurantestdrsource -g test-stg-dr --expand geoReplicationStats --query "{resourceGroup: resourceGroup, name: name, location: location, secondaryLocation: secondaryLocation,  lastSyncTime: geoReplicationStats.lastSyncTime}" -o table
```
