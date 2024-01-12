# adf-sql-AddADFtoSQLasUser

Make service connection in Devops to Azure. Then 

- Change the SerivceConnect name in Globals variable yaml file in DevOps folder (to the name of the service connection you made above)
- Change the SubscriptionIdGHUB variable in each variable yaml file for test, ppe and prod
- Add your DevOps service Connection as a User Access Administrator in RBAC in your subscription. 
 - Also, add your service connection app registration (service principal) to the SQL-DataWriters-DEV (TEST and PROD will have their own AD groups too if you so wish)
- Change your tenantID in keyvault ARM template to your own tenantID
- Change the GIT settings under Infrasturcture/ArmTemplates/AzureSQL/DEV to fit your own GitHub settings. Once this deploys the first time you must log into github on the data factory, then click on the browser refresh button if it doesn't show up under git configuration tab in the ADF

New additions
 - added random name generation to SQL server and ADF. Then used PowerShell to get the names from the deployment Output and passed them through
 - I updated the dacpac to include sprocs and load info watermark table

Users who deploy this must add the ADF as an AD user to the SQL server, but first you must manually add your own AD account as admin to the SQL server using the Entra ID blade on the SQL server in the azure portal 

# Important parts

## SQL admins
In order for this powershell script to work "\adf-and-sql-incremental-load\DevOps\Tasks\Utils\AddSGObjectidToSQLserverAsUser.ps1" the Service Connection that you make in Azure Devops to your Azure subscripition will be used to execute this script. This means that the Service principal itself needs to be a SQL SERVER ADMINISTRATOR! 

Its best to make a Microsoft Entra ID GROUP, this code project does not include the making of these groups so as a pre requisite you have to have made the Security groups ahead of time and added your ADO (azure devops) service principal to your security group ()