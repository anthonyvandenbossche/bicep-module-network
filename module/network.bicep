@allowed([
  'westeurope'
  'northeurope'
])
param location string
@allowed([
  'integration'
  'acceptance'
  'production'
])
param environment string
param purpose string
param addressPrefixes array
param subnetPrefix string

var envShort = {
  production: 'prd'
  acceptance: 'acc'
  integration: 'int'
}
var locShort = {
  westeurope: 'we'
  northeurope: 'ne'
}
var vNetName = 'vnet-${envShort[environment]}-${locShort[location]}'
var subnetName = '${purpose}-sn'
var nsgName = '${subnetName}-nsg'

resource myNSG 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgName
  location:location
  properties:{
    securityRules:[
      {
        name: 'AllowSSH'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          direction: 'Inbound'
          priority: 1000
        }
      }
    ]
  }
}

resource myVNET 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup:{
            id:myNSG.id
          }
        }
      }
    ]
  }
}





output outputSubnetID string = myVNET.properties.subnets[0].id
