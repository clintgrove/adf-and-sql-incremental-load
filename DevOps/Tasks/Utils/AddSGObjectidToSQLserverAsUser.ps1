param (
  [String] $aadGroupName = 'SQL-DataWriters-DEV',
  [String] $dbRoleName = 'ADFReadWriteToTables',
  [String] $db_server = 'sqlsrv-j4ckpfb4gepfo-dev.database.windows.net',
  [String] $db_name = 'dba-fac-stf-source'
)
# idea from https://medium.com/microsoftazure/deploying-a-dacpac-to-azure-with-azure-pipelines-and-managed-identity-89703d405e00

$aadGroupObjectId = (Get-AzADGroup -DisplayName $aadGroupName).id #az ad group show --group $aadGroupName --query objectId

WRITE-HOST $aadGroupObjectId
Get-AzContext

$context = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext
$sqlToken = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id.ToString(), $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null, "https://database.windows.net").AccessToken
#Write-Host ("##vso[task.setvariable variable=SQLTOKEN;]$sqlToken")  

Write-Verbose "Get SID"
$objId=$aadGroupObjectId.Trim('"')
function ConvertTo-Sid {
param (
[string]$objectId
)
[guid]$guid = [System.Guid]::Parse($objectId)
foreach ($byte in $guid.ToByteArray()) {
$byteGuid += [System.String]::Format("{0:X2}", $byte)
}
return "0x" + $byteGuid
}
$SID=ConvertTo-Sid($objId)
Write-Verbose "Create SQL connectionstring"
$conn = New-Object System.Data.SqlClient.SQLConnection
$conn.ConnectionString = "Server=$db_server;Initial Catalog=$db_name;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30"
$conn.AccessToken = $sqlToken
Write-Verbose "Connect to database and execute SQL script"
$conn.Open()
$query = "IF NOT EXISTS (SELECT [name]
FROM [sys].[database_principals]
WHERE [type] = N'X' AND [name] = N'$aadGroupName')
BEGIN
CREATE USER [$aadGroupName] WITH DEFAULT_SCHEMA=[dbo], SID = $SID, TYPE= X;
ALTER ROLE [$dbRoleName] ADD MEMBER [$aadGroupName];
END
"
Write-Host $query
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $conn)
$Result = $command.ExecuteNonQuery()
$conn.Close()
