#!/bin/bash

clear

displayHeader() {
	echo -e "\n======================================================================================"
	echo $1
	echo -e "======================================================================================\n"
}

SUBSCRIPTION="b8edf275-3c09-40ed-b1e6-b26c2703c3e0"
RESOURCEGROUP="Relay"
RESET='false'

while getopts 'r' OPT; do
    case "$OPT" in
        r) 
			RESET='true' ;;
    esac
done

if [ "$(az group exists --subscription $SUBSCRIPTION -g $RESOURCEGROUP)" == "false" ]; then

	displayHeader "Creating resource group ..."
	az group create \
		--subscription $SUBSCRIPTION \
		-n $RESOURCEGROUP \
		-l westeurope \
		--only-show-errors \
		-o none && echo "... done"

elif [ "$RESET" == "true" ]; then

	displayHeader "Resetting resource group ..."
	az deployment group create \
		--subscription $SUBSCRIPTION \
		-g $RESOURCEGROUP \
		-n $(uuidgen) \
		--mode Complete \
		--template-uri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/100-blank-template/azuredeploy.json \
		--only-show-errors \
		-o none && echo "... done"

fi

displayHeader "Deploying resources ..."
az deployment group create \
	--subscription $SUBSCRIPTION \
	-g $RESOURCEGROUP \
	-n $(uuidgen) \
	--mode Complete \
	--template-file ./resources/main.bicep \
	--only-show-errors \
	--parameters \
		DeploymentConfig=@./deploy.json