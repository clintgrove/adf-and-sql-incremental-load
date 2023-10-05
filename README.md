# adf-sql-AddADFtoSQLasUser

Make service connection in Devops to Azure. Then change the SerivceConnect name in Globals variable yaml file in DevOps folder

Change the SubscriptionIdGHUB variable in each variable yaml file for test, ppe and prod

Add your DevOps service Connection as a User Access Administrator in RBAC in your subscription. 
 
Change your tenantID in keyvault ARM template to your own tenantID

TODO 
- The sql server name in variables folder is fixed to my server name. the deployment randomly makes a unique id
- the connection linked services in ADF point to keyvault secret to another SQL server
- the dacpac does not include sprocs needed to do the incremental load
