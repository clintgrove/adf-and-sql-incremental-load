param (
    #[Parameter(Mandatory=$true)]
    [String] $AD_SecurityGroup ,
    #[Parameter(Mandatory=$true)] 
    [String] $FactoryNameUpToEnv
)

$idOfSecGroup = (Get-AzADGroup -DisplayName $AD_SecurityGroup).id
write-host $idOfSecGroup
$idOfFactory = (Get-AzADServicePrincipal -DisplayNameBeginsWith $FactoryNameUpToEnv).id
write-host $idOfFactory

Add-AzADGroupMember -TargetGroupObjectId $idOfSecGroup -MemberObjectId $idOfFactory


