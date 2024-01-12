param (
    #[Parameter(Mandatory=$true)]
    [String] $AD_SecurityGroup = 'SQL-DataWriters-DEV',
    #[Parameter(Mandatory=$true)] 
    [String] $FactoryNameUpToEnv = 'adf-rcv6lib6rdt2c-uksouth-dev'
)

$idOfSecGroup = (Get-AzADGroup -DisplayName $AD_SecurityGroup).id
write-host $idOfSecGroup
$idOfFactory = (Get-AzADServicePrincipal -DisplayNameBeginsWith $FactoryNameUpToEnv).id
write-host $idOfFactory

try {
    Add-AzADGroupMember -TargetGroupObjectId $idOfSecGroup -MemberObjectId $idOfFactory -ErrorAction SilentlyContinue
}
catch {
    if ($_.Exception.Message -like "*One or more added object references already exist for the following modified properties: 'members'*") {
        Write-Host "Member already exists in the group, continuing..."
    }
    else {
        throw
    }
}