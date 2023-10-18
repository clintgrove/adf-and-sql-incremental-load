# adf-sql-AddADFtoSQLasUser

Make service connection in Devops to Azure. Then change the SerivceConnect name in Globals variable yaml file in DevOps folder

Change the SubscriptionIdGHUB variable in each variable yaml file for test, ppe and prod

Add your DevOps service Connection as a User Access Administrator in RBAC in your subscription. 
 
Change your tenantID in keyvault ARM template to your own tenantID

New additions
 - added random name generation to SQL server and ADF. Then used PowerShell to get the names from the deployment Output and passed them through
 - I updated the dacpac to include sprocs and load info watermark table

Users who deploy this must add the ADF as an AD user to the SQL server, but first you must manually add your own AD account as admin to the SQL server using the Entra ID blade on the SQL server in the azure portal 
