param (

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $Location = "ReadFromVariable_Infra-Common_Location",
        
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $ResourceGroupName = 'ReadFromVariable_Infra-<Env>_ResourceGroup',
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $AKSName = 'ReadFromVariable_Infra-<Env>_AKSName',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $VNETName = 'ReadFromVariable_Infra-<Env>_VirtualNetworkName',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $AKSSubnetName = 'AksSubnet',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $APPGateWayName = 'ReadFromVariable_Infra-<Env>_AppGatewayName',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $APPGateWayNameSubnetName = 'AppGatewaySubnet',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $LogWorkspaceName = 'ReadFromVariable_Infra-<Env>_LogAnalyticsWorkspaceName',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $KubernetesVersion = "ReadFromVariable_Infra-<Env>_KubernetesVersion",
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $WindowsAdminUsername = "ReadFromVariable_Infra-<Env>_WindowsAdminUsername",
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $WindowsAdminPassword = "ReadFromVariable_Infra-Secrets-SIT_WindowsAdminPassword",
    
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $AKSSystemNodeCount = "ReadFromVariable_Infra-<Env>_AKSSystemNodeCount",
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $AADProfileAdminGroupObjectIDs = "ReadFromVariable_Infra-<Env>_AADProfileAdminGroupObjectIDs",
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $ServiceCIDR = "ReadFromVariable_Infra-<Env>_ServiceCIDR",
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $DNSServiceIP ="ReadFromVariable_Infra-<Env>_DNSServiceIP",
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $DockerBridgeAddress ="ReadFromVariable_Infra-<Env>_DockerBridgeAddress",
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $MaxSystemPods ="ReadFromVariable_Infra-<Env>_MaxSystemPods",
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $AvailabilityZones ="ReadFromVariable_Infra-<Env>_AvailabilityZones",
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $SystemNodeVMSize ="ReadFromVariable_Infra-<Env>_SystemNodeVMSize",
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $SystemNodePoolName ="ReadFromVariable_Infra-<Env>_SystemNodePoolName",
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $SystemNodePoolNodeLabels = "ReadFromVariable_Infra-<Env>_SystemNodePoolNodeLabels",
       
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $UserNodePoolName1 =  "ReadFromVariable_Infra-<Env>_UserNodePoolName1",

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $UserNodePoolName2 =  "ReadFromVariable_Infra-<Env>_UserNodePoolName2",
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $UserNodeVMSize = "ReadFromVariable_Infra-<Env>_UserNodeVMSize",
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $MaxUserPods = "ReadFromVariable_Infra-<Env>_MaxUserPods",
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $AKSUserNodeCount = "ReadFromVariable_Infra-<Env>_AKSUserNodeCount",
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $UserNodePoolNodeLabels = "ReadFromVariable_Infra-<Env>_UserNodePoolNodeLabels",

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $OSDiskSize = "ReadFromVariable_Infra-<Env>_OSDiskSize",  
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]  $SystemNodePoolNodeTags =  "ReadFromVariable_Infra-<Env>_SystemNodePoolNodeTags",   
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]  $UserNodePoolNodeTags = 'ReadFromVariable_Infra-<Env>_UserNodePoolNodeTags',
   
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]  $AKSManagedIdentity = "ReadFromVariable_Infra-<Env>_AKSManagedidentity" ,
    
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $UserNodePoolNodeLabels2 = "ReadFromVariable_Infra-<Env>_UserNodePoolNodeLabels2"

)

az configure --defaults group=$ResourceGroupName

#Create RBAC Managed identities for AppGw access the Environment

Write-Host "--- Create Managed Identity for AKS User Managed Identies---" -ForegroundColor Cyan

#az identity create -n $AppGWManagedidentity -g $ResourceGroupName -l westeurope --query principalId -o tsv

az identity create `
  --resource-group $ResourceGroupName `
  --name $AKSManagedIdentity

Write-Host "--- Complete: Managed Identity completed for AKS User Managed Identies  ---" -ForegroundColor Green

# Get service Resource ID of the user-assigned identity

Write-Host "--- Generate service Resource ID & assign Network gateway Managed Identity to AKS Env---" -ForegroundColor Cyan

$AKSID=$(az identity show `
--resource-group $ResourceGroupName `
--name $AKSManagedidentity --query id --output tsv)

$AKSSubnetID=$(az network vnet subnet show -g $ResourceGroupName --vnet-name $VNETName --name $AKSSubnetName --query id -o tsv)

$AppGatewayId=$(az network application-gateway show -n $APPGateWayName -g $ResourceGroupName -o tsv --query "id") 

$LogWorkspaceId=$(az monitor log-analytics workspace show --resource-group $ResourceGroupName --workspace-name $LogWorkspaceName --query id -o tsv)

$AKSID
$AKSSubnetID
$AppGatewayId
$LogWorkspaceId

Write-Host "--- Generated service Resource ID & assign Network gateway Managed Identity to AKS Env---" -ForegroundColor Green

# create AKS instances
Write-Host "--- Creating AKS Instance K8s version $aksVersion ---" -ForegroundColor Cyan

az aks create --resource-group $ResourceGroupName `
    --name $AKSName `
    --kubernetes-version $KubernetesVersion `
    --location $Location `
    --windows-admin-username $WindowsAdminUsername `
    --windows-admin-password $WindowsAdminPassword `
    --vm-set-type VirtualMachineScaleSets `
    --node-count $AKSSystemNodeCount `
    --generate-ssh-keys `
    --network-plugin azure `
    --network-policy azure `
    --outbound-type userDefinedRouting `
    --enable-managed-identity `
    --assign-identity $AKSID `
    --aad-admin-group-object-ids $AADProfileAdminGroupObjectIDs `
    --service-cidr $ServiceCIDR `
    --dns-service-ip $DNSServiceIP `
    --docker-bridge-address $DockerBridgeAddress `
    --vnet-subnet-id $AKSSubnetID `
    --appgw-id $AppGatewayId `
    --enable-addons monitoring,ingress-appgw,azure-policy `
    --enable-aad `
    --enable-azure-rbac `
    --max-pods $MaxSystemPods `
    --zones $AvailabilityZones `
    --node-vm-size $SystemNodeVMSize `
    --node-osdisk-type Ephemeral `
    --node-osdisk-size $OSDiskSize `
    --nodepool-name $SystemNodePoolName `
    --nodepool-labels $SystemNodePoolNodeLabels `
    --workspace-resource-id $LogWorkspaceId `
    --tags $SystemNodePoolNodeTags   

# add windows server nodepool
Write-Host "--- Creating Windows Server Node Pool ---" -ForegroundColor Cyan

$aksSystemNodePoolExists=$(az aks nodepool list -g $ResourceGroupName --cluster-name $AksName --query "[?name=='$UserNodePoolName1'].name" -o tsv --only-show-errors)
if (($aksSystemNodePoolExists -eq "") -or ($aksSystemNodePoolExists -eq $null))

{
    az aks nodepool add --resource-group $ResourceGroupName `
    --cluster-name $AKSName `
    --os-type Windows `
    --name $UserNodePoolName1 `
    --node-vm-size $UserNodeVMSize `
    --node-osdisk-type Ephemeral `
    --node-osdisk-size $OSDiskSize `
    --zones $AvailabilityZones `
    --vnet-subnet-id $AKSSubnetID `
    --mode user `
    --max-pods $MaxUserPods `
    --node-count $AKSUserNodeCount `
    --labels $UserNodePoolNodeLabels `
    --tags $UserNodePoolNodeTags 
}
else

{   az aks nodepool update --resource-group $ResourceGroupName `
   --cluster-name $AKSName `
    --name $UserNodePoolName1 `
    --mode user `
    --tags $UserNodePoolNodeTags 
}

Write-Host "--- Checking if Second Windows Server Node Pool is Required ---" -ForegroundColor Cyan

if($UserNodePoolName2 -ne "NA")
{
Write-Host "--- Creating Second Windows Server Node Pool ---" -ForegroundColor Cyan
    $aksUserNodePoolExists=$(az aks nodepool list -g $ResourceGroupName --cluster-name $AksName --query "[?name=='$UserNodePoolName2'].name" -o tsv --only-show-errors)
    if (($aksUserNodePoolExists -eq "") -or ($aksUserNodePoolExists -eq $null))

    {
        az aks nodepool add --resource-group $ResourceGroupName `
        --cluster-name $AKSName `
        --os-type Windows `
        --name $UserNodePoolName2 `
        --node-vm-size $UserNodeVMSize `
        --node-osdisk-type Ephemeral `
        --node-osdisk-size $OSDiskSize `
        --zones $AvailabilityZones `
        --vnet-subnet-id $AKSSubnetID `
        --mode user `
        --max-pods $MaxUserPods `
        --node-count $AKSUserNodeCount `
        --labels $UserNodePoolNodeLabels2 `
        --tags $UserNodePoolNodeTags 

    }
    else

    {   az aks nodepool update --resource-group $ResourceGroupName `
       --cluster-name $AKSName `
        --name $UserNodePoolName2 `
        --mode user `
        --tags $UserNodePoolNodeTags 

    }
}
Write-Host "--- Complete: AKS Created ---" -ForegroundColor Green