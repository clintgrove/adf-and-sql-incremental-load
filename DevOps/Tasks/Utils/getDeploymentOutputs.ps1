param(
[String] [Parameter(Mandatory = $true)] $resourceGroupName
)

#https://stackoverflow.com/questions/36948549/how-do-i-use-arm-outputs-values-another-release-task

#$resourceGroupName = 'lz-ghub-test-uks-rg-01'
$lastDeployment = Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName | Sort Timestamp -Descending | Where-Object {$_.DeploymentName -like "AzureSQL*"} | Select -First 1

if(!$lastDeployment) {
    throw "Deployment could not be found for Resource Group '$resourceGroupName'."
}

if(!$lastDeployment.Outputs) {
    throw "No output parameters could be found for the last deployment of Resource Group '$resourceGroupName'."
}

foreach ($key in $lastDeployment.Outputs.Keys){
    $type = $lastDeployment.Outputs.$key.Type
    $value = $lastDeployment.Outputs.$key.Value

    if ($type -eq "SecureString") {
        Write-Host "##vso[task.setvariable variable=$key;issecret=true]$value" 
    }
    else {
        if ($key -eq "armOutput") {
            Write-Host "##vso[task.setvariable variable=sqlSrvNameOutput;isOutput=true]$value"
        }
        #Write-Host "##vso[task.setvariable variable=sqlSrvNameOutput;isOutput=true]$value"
        #Write-Host "##vso[task.setvariable variable=$key;]$value"  
    }
}

