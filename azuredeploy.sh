#!/bin/bash
clear

TARGET_SUBSCRIPTION="929097d0-4c3c-47d7-b59e-e5e609f1d71f"
TARGET_RESOURCEGROUP="Relay"

echo "Selecting subscription ..."
az account set --subscription $TARGET_SUBSCRIPTION

if [ "$(az group exists -g $TARGET_RESOURCEGROUP)" == "false" ]; then

	echo "Creating resource group ..."
	az group create -n $TARGET_RESOURCEGROUP -l westeurope

elif [ "$1" == "reset" ]; then

	echo "Resetting resource group ..."
	az deployment group create -g $TARGET_RESOURCEGROUP -n $(date +%s) --mode Complete --template-uri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/100-blank-template/azuredeploy.json -o none && sleep 2m

fi

echo "Deploying resources ..."
az deployment group create -g $TARGET_RESOURCEGROUP -n $(date +%s) --mode Complete --template-file azuredeploy.json --parameters @azuredeploy.parameters.json -o none
