targetScope = 'resourceGroup'

// =============================================================================================

param DeploymentConfig object

// =============================================================================================

var ResourcePrefix = 'Relay'
var ResourceLocation = resourceGroup().location

var VNetV4AddressRange = '10.0.0.0/16'
var SNetV4AddressRange = '10.0.0.0/24'

var VNetV6AddressRange = 'ace:cab:deca::/48'
var SNetV6AddressRange = 'ace:cab:deca:deed::/64'

var Setup6TunnelArguments = ''

var InitScriptBaseUri = 'https://raw.githubusercontent.com/markusheiliger/6tunnel-relay/main/resources/scripts/'
var InitScriptNames = [ 'initMachine.sh', 'setup6Tunnel.sh' ]
var InitCommand = join(filter([
  './initMachine.sh '
  './setup6Tunnel.sh ${Setup6TunnelArguments}'
  'sudo shutdown -r 1'
], item => !empty(item)), ' && ')


// =============================================================================================


resource publicIPV4 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: '${ResourcePrefix}-IPv4'
  location: ResourceLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource publicIPV6 'Microsoft.Network/publicIPAddresses@2023-02-01' = {
  name: '${ResourcePrefix}-IPv6'
  location: ResourceLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv6'
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-02-01' = {
  name: ResourcePrefix
  location: ResourceLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        VNetV4AddressRange
        VNetV6AddressRange
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefixes: [
            SNetV4AddressRange
            SNetV6AddressRange
          ]
        }
      }
    ]
  }
}

resource defaultSubNet 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' existing = {
  name: 'default'
  parent: virtualNetwork
}

resource relayNSG 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: ResourcePrefix
  location: ResourceLocation
  properties: {
    securityRules: [
      {
        name: 'allow-SSH-in'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 1000
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

resource relayNIC 'Microsoft.Network/networkInterfaces@2023-02-01' = {
  name: ResourcePrefix
  location: ResourceLocation
  properties: {
    networkSecurityGroup: {
      id: relayNSG.id
    }
    ipConfigurations: [
      {
        name: 'ipconfig-v4'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'
          primary: true
          subnet: {
            id: defaultSubNet.id
          }
          publicIPAddress: {            
            id: publicIPV4.id
          }
        }
      }
      {
        name: 'ipconfig-v6'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv6'
          primary: false
          subnet: {
            id: defaultSubNet.id
          }
          publicIPAddress: {
            id: publicIPV6.id
          }
        }
      }
    ]
  }
}

resource relayVM 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: ResourcePrefix
  location: ResourceLocation
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1ls'
    }
    osProfile: {
      computerName: '${ResourcePrefix}-${uniqueString(resourceGroup().id)}'
      adminUsername: DeploymentConfig.credentials.username
      adminPassword: DeploymentConfig.credentials.password
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: relayNIC.id
        }
      ]
    }
  }
}

resource relayInit 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  name: 'init'
  location: ResourceLocation
  parent: relayVM
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    forceUpdateTag: guid(deployment().name)
    autoUpgradeMinorVersion: true
    settings: {      
      fileUris: map(InitScriptNames, name => uri(InitScriptBaseUri, name))
      commandToExecute: InitCommand
    }
  }
}
