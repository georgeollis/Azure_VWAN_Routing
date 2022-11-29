export LOCATION=uksouth
export VWANNAME=vwan
export virtual_hub_1=hub01
export RESOURCEGROUPNAME=rg-vwan-demo
export virtual_hub_1_address_prefix=192.168.0.0/24

export blue_virtual_network_name_1=vnet-blue-spoke-01
export blue_virtual_network_1_address_prefix=192.168.1.0/24
export blue_virtual_network_name_2=vnet-blue-spoke-02
export blue_virtual_network_2_address_prefix=192.168.3.0/24

export red_virtual_network_name_1=vnet-red-spoke-01
export red_virtual_network_1_address_prefix=192.168.2.0/24
export red_virtual_network_name_2=vnet-red-spoke-02
export red_virtual_network_2_address_prefix=192.168.4.0/24

az group create --name $RESOURCEGROUPNAME --location $LOCATION

az network vwan create --name $VWANNAME --resource-group $RESOURCEGROUPNAME --location $LOCATION --type Standard
export vwan_resource_id=$(az network vwan list --resource-group $RESOURCEGROUPNAME --query "[?name=='$VWANNAME'].id" -o tsv)

az network vhub create --name $virtual_hub_1 --resource-group $RESOURCEGROUPNAME --address-prefix $virtual_hub_1_address_prefix --location $LOCATION --vwan $vwan_resource_id
az network vhub wait --name $virtual_hub_1 --resource-group $RESOURCEGROUPNAME --created

az network vnet create --name $blue_virtual_network_name_1 --resource-group $RESOURCEGROUPNAME --address-prefixes $blue_virtual_network_1_address_prefix --location $LOCATION
az network vnet create --name $blue_virtual_network_name_2 --resource-group $RESOURCEGROUPNAME --address-prefixes $blue_virtual_network_2_address_prefix --location $LOCATION

az network vnet subnet create --address-prefixes $blue_virtual_network_1_address_prefix --name blue-workload-1 --resource-group $RESOURCEGROUPNAME --vnet-name $blue_virtual_network_name_1
az network vnet subnet create --address-prefixes $blue_virtual_network_2_address_prefix --name blue-workload-2 --resource-group $RESOURCEGROUPNAME --vnet-name $blue_virtual_network_name_2

az network vnet create --name $red_virtual_network_name_1 --resource-group $RESOURCEGROUPNAME --address-prefixes $red_virtual_network_1_address_prefix --location $LOCATION
az network vnet create --name $red_virtual_network_name_2 --resource-group $RESOURCEGROUPNAME --address-prefixes $red_virtual_network_2_address_prefix --location $LOCATION

az network vnet subnet create --address-prefixes $red_virtual_network_1_address_prefix --name red-workload-1 --resource-group $RESOURCEGROUPNAME --vnet-name $red_virtual_network_name_1
az network vnet subnet create --address-prefixes $red_virtual_network_2_address_prefix --name red-workload-2 --resource-group $RESOURCEGROUPNAME --vnet-name $red_virtual_network_name_2

az vm create --resource-group $RESOURCEGROUPNAME --name linux-blue-1 --location $LOCATION --image Canonical:UbuntuServer:19_10-daily-gen2:19.10.202007100 --vnet-name $blue_virtual_network_name_1 --subnet blue-workload-1 --admin-username azureuser  --admin-password Th1sIsOurDemo12345! --size standard_b2ms --public-ip-address ""
az vm create --resource-group $RESOURCEGROUPNAME --name linux-blue-2 --location $LOCATION --image Canonical:UbuntuServer:19_10-daily-gen2:19.10.202007100 --vnet-name $blue_virtual_network_name_2 --subnet blue-workload-2 --admin-username azureuser  --admin-password Th1sIsOurDemo12345! --size standard_b2ms --public-ip-address ""
az vm create --resource-group $RESOURCEGROUPNAME --name linux-red-1 --location $LOCATION --image Canonical:UbuntuServer:19_10-daily-gen2:19.10.202007100 --vnet-name $red_virtual_network_name_1 --subnet red-workload-1 --admin-username azureuser  --admin-password Th1sIsOurDemo12345! --size standard_b2ms --public-ip-address ""
az vm create --resource-group $RESOURCEGROUPNAME --name linux-red-2 --location $LOCATION --image Canonical:UbuntuServer:19_10-daily-gen2:19.10.202007100 --vnet-name $red_virtual_network_name_2 --subnet red-workload-2 --admin-username azureuser  --admin-password Th1sIsOurDemo12345! --size standard_b2ms --public-ip-address ""

az network vhub route-table create --name blue-route-table --resource-group $RESOURCEGROUPNAME --vhub-name $virtual_hub_1 --labels blue
az network vhub route-table create --name red-route-table --resource-group $RESOURCEGROUPNAME --vhub-name $virtual_hub_1 --labels red

export blue_route_table_id=$(az network vhub route-table show --name blue-route-table --resource-group $RESOURCEGROUPNAME --vhub-name $virtual_hub_1 --query "id" -o tsv)
export red_route_table_id=$(az network vhub route-table show --name red-route-table --resource-group $RESOURCEGROUPNAME --vhub-name $virtual_hub_1 --query "id" -o tsv)
export virtual_network_id_blue_01=$(az network vnet show --name $blue_virtual_network_name_1 --resource $RESOURCEGROUPNAME --query "id" -o tsv)
export virtual_network_id_blue_02=$(az network vnet show --name $blue_virtual_network_name_2 --resource $RESOURCEGROUPNAME --query "id" -o tsv)
export virtual_network_id_red_01=$(az network vnet show --name $red_virtual_network_name_1 --resource $RESOURCEGROUPNAME --query "id" -o tsv)
export virtual_network_id_red_02=$(az network vnet show --name $red_virtual_network_name_2 --resource $RESOURCEGROUPNAME --query "id" -o tsv)

az network vhub connection create --name blue-spoke01 --remote-vnet $virtual_network_id_blue_01 --resource-group $RESOURCEGROUPNAME --vhub-name $virtual_hub_1 --associated $blue_route_table_id --labels blue --internet-security false
az network vhub connection create --name blue-spoke02 --remote-vnet $virtual_network_id_blue_02 --resource-group $RESOURCEGROUPNAME --vhub-name $virtual_hub_1 --associated $blue_route_table_id --labels blue --internet-security false
az network vhub connection create --name red-spoke02 --remote-vnet $virtual_network_id_red_01 --resource-group $RESOURCEGROUPNAME --vhub-name $virtual_hub_1 --associated $red_route_table_id --labels red --internet-security false
az network vhub connection create --name red-spoke02 --remote-vnet $virtual_network_id_red_02 --resource-group $RESOURCEGROUPNAME --vhub-name $virtual_hub_1 --associated $red_route_table_id --labels red --internet-security false

        
                                  
