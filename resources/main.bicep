targetScope = 'subscription'

// =============================================================================================

param RelayConfig object

// =============================================================================================

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '6tunnel-Relay'
  location: RelayConfig.location
}

module relayDeploy 'relay.bicep' = {
  name: '${take(deployment().name, 36)}_${uniqueString(string(RelayConfig), 'relayDeploy')}'
  scope: resourceGroup
  params: {
    RelayConfig: RelayConfig
  }
}
