param(
[String] [Parameter(Mandatory = $true)] $resourceGroupName
)

#https://stackoverflow.com/questions/36948549/how-do-i-use-arm-outputs-values-another-release-task

#$resourceGroupName = 'lz-ghub-test-uks-rg-01'
$lastSQLDeployment = Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName | Sort Timestamp -Descending | Where-Object {$_.DeploymentName -like "AzureSQL*"} | Select -First 1

if(!$lastSQLDeployment) {
    throw "Deployment could not be found for Resource Group '$resourceGroupName'."
}

if(!$lastSQLDeployment.Outputs) {
    throw "No output parameters could be found for the last deployment of Resource Group '$resourceGroupName'."
}

foreach ($key in $lastSQLDeployment.Outputs.Keys){
    $type = $lastSQLDeployment.Outputs.$key.Type
    $value = $lastSQLDeployment.Outputs.$key.Value

    if ($type -eq "SecureString") {
        Write-Host "##vso[task.setvariable variable=$key;issecret=true]$value" 
    }
    else {
        if ($key -eq "armOutput") {
            Write-Host "##vso[task.setvariable variable=sqlSrvNameOutput;isOutput=true]$value"
        } 
    }
}

$lastADFDeployment = Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName | Sort Timestamp -Descending | Where-Object {$_.DeploymentName -like "AzureDataFac*"} | Select -First 1

if(!$lastADFDeployment) {
    throw "Deployment could not be found for Resource Group '$resourceGroupName'."
}

if(!$lastADFDeployment.Outputs) {
    throw "No output parameters could be found for the last deployment of Resource Group '$resourceGroupName'."
}

foreach ($key in $lastADFDeployment.Outputs.Keys){
    $type = $lastADFDeployment.Outputs.$key.Type
    $value = $lastADFDeployment.Outputs.$key.Value

    if ($type -eq "SecureString") {
        Write-Host "##vso[task.setvariable variable=$key;issecret=true]$value" 
    }
    else {
        if ($key -eq "adfNameOutput") {
            Write-Host "##vso[task.setvariable variable=adfNameOutput;isOutput=true]$value"
        }

    }
}

