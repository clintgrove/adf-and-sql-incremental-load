param(
[String] [Parameter(Mandatory = $true)] $resourceGroupName
)

#https://stackoverflow.com/questions/36948549/how-do-i-use-arm-outputs-values-another-release-task

#$resourceGroupName = 'lz-ghub-test-uks-rg-01'
$lastDeployment = Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName | Sort Timestamp -Descending | Select -First 1 

if(!$lastDeployment) {
    throw "Deployment could not be found for Resource Group '$resourceGroupName'."
}

if(!$lastDeployment.Outputs) {
    throw "No output parameters could be found for the last deployment of Resource Group '$resourceGroupName'."
}

$sqlSrvNameOutput = $lastDeployment.Outputs.armOutput.Value
Write-Host "##vso[task.setvariable variable=sqlSrvNameOutput;isOutput=true]$sqlSrvNameOutput"
Write-Host "The sqlServerName variable is $sqlSrvNameOutput"