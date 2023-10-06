param(
 [string]  $resourceGroupName
)
Import-Module -Name Az.Resources

$resourceGroupName = 'lz-ghub-test-uks-rg-01'
$lastDeployment = Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName | Sort Timestamp -Descending | Select -First 1 
$deploymentOutputs = $lastDeployment.Outputs

# $deploymentOutputs.GetEnumerator() | % {
#     $_.Value.Value


# }