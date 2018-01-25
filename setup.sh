#!/bin/bash
# Demo Red Hat Single Sign On
# @author Rodrigo Ramalho - rramalho@redhat.com
#                           github.com/hodrigohamalho
# This script shouldn't be updated
# all settings is on setup.env.sh file
# Install EAP 7 and SSO.
# Install EAP 7 SSO adapters: SAML and OpenID

. setup-env.sh

function validateRequirements(){
	command -v mvn -q >/dev/null 2>&1 || { echo >&2 "Maven is required but not installed or not present in thet system PATH yet... aborting."; exit 1; }
	command -v git --version >/dev/null 2>&1 || { echo >&2 "Git is required but not installed or not present in thet system PATH yet... aborting."; exit 1; }

	# make some checks first before proceeding.
	if [ -r $EAP_INSTALLER ] || [ -L $EAP_INSTALLER ]; then
		printf "\n JBoss EAP installer is present..."
	else
		printf "\n Need to download EAP package from the Customer Portal"
		printf "\n\t and place it in the $BINARIES_DIR directory to proceed... \n"
		exit
	fi

	if [ -r $SSO_INSTALLER ] || [ -L $SSO_INSTALLER ]; then
			printf "\n JBoss SSO installer is present... \n"
	else
			printf "\n Need to download SSO installer from the Customer Portal"
			printf "\n\t and place it in the $BINARIES_DIR directory to proceed... \n"
			exit
	fi
}

function installEAP(){
	printf "\n Installing EAP, please wait..."

	unzip -q $EAP_INSTALLER -d $TARGET_DIR
	rm $EAP_HOME/bin/*.bat

	if [ $? -ne 0 ]; then
		printf "\n Error occurred during JBoss EAP installation!"
		exit
	fi

	printf "\n EAP Admin crential created"
	printf "\n\t User: admin"
	printf "\n\t Pass: admin"
	$EAP_HOME/bin/add-user.sh -u admin -p admin -s
	printf "\n Installing RH SSO EAP 7 Adapter"
	unzip -oq $EAP_SSO_ADAPTER -d $EAP_HOME
	printf "\n Installing RH SSO EAP 7 SAML Adapter \n\n"
	unzip -oq $EAP_SSO_SAML_ADAPTER -d $EAP_HOME

	$EAP_HOME/bin/standalone.sh > /dev/null &
	sleep $JBOSS_STARTUP_TIME
	
	$EAP_HOME/bin/jboss-cli.sh -c --file=$EAP_HOME/bin/adapter-install.cli > /dev/null
	$EAP_HOME/bin/jboss-cli.sh -c ":reload" 
	$EAP_HOME/bin/jboss-cli.sh -c --file=$EAP_HOME/bin/adapter-install-saml.cli > /dev/null
	$EAP_HOME/bin/jboss-cli.sh -c ":reload" 
	
	EAP_PROC_ID=$(ps -ef | awk '/jbos[s]/ {print $2}')
	kill -9 $EAP_PROC_ID
}

function installSSO(){
	printf "\n Installing SSO, please wait..."

	unzip -q $SSO_INSTALLER -d $TARGET_DIR
	rm $SSO_HOME/bin/*.bat
	
	printf "\n RH SSO Admin crential created"
	printf "\n\t User: admin"
	printf "\n\t Pass: admin"
	$SSO_HOME/bin/add-user-keycloak.sh -u admin -p admin

	if [ $? -ne 0 ]; then
		printf "\n Error occurred during JBoss SSO installation!"
		exit
	fi
}

function uninstall(){
	echo "Removing previously installation (if exists)"
	rm -rf $TARGET_DIR/*	
}

function deployQuickstarts(){
	if [ ! -d "redhat-sso-quickstarts" ]; then
		git clone https://github.com/redhat-developer/redhat-sso-quickstarts
	fi

	cp redhat-sso-quickstarts/service-jee-jaxrs/config/keycloak-example.json redhat-sso-quickstarts/service-jee-jaxrs/config/keycloak.json
	cp redhat-sso-quickstarts/app-profile-jee-html5/config/keycloak-example.json redhat-sso-quickstarts/app-profile-jee-html5/config/keycloak.json
	cp redhat-sso-quickstarts/app-jee-jsp/config/keycloak-example.json redhat-sso-quickstarts/app-jee-jsp/config/keycloak.json

	mvn -f redhat-sso-quickstarts/service-jee-jaxrs/pom.xml clean install wildfly:deploy -DskipTests 
	mvn -f redhat-sso-quickstarts/app-profile-jee-html5/pom.xml clean install wildfly:deploy -DskipTests
	mvn -f redhat-sso-quickstarts/app-jee-jsp/pom.xml clean install wildfly:deploy -DskipTests
}

function importQuickstartsInKeycloak(){
	sh install/rh-sso-7.1/bin/kcadm.sh config credentials --server http://localhost:8180/auth --realm master --user admin --password admin
	sh install/rh-sso-7.1/bin/kcadm.sh create clients -r master -f redhat-sso-quickstarts/service-jee-jaxrs/config/client-import.json
	sh install/rh-sso-7.1/bin/kcadm.sh create clients -r master -f redhat-sso-quickstarts/app-profile-jee-html5/config/client-import.json
	sh install/rh-sso-7.1/bin/kcadm.sh create clients -r master -f redhat-sso-quickstarts/app-jee-jsp/config/client-import.json
}

case "$1" in
	install)
		uninstall
		validateRequirements
		installEAP
		installSSO
		;;
	uninstall)
		uninstall
		;;
	start)
		nohup $SSO_HOME/bin/standalone.sh -Djboss.socket.binding.port-offset=100 > sso.log &
		printf "\n SSO starting... check http://localhost:9990"
		printf "\n\t User: admin"
		printf "\n\t Pass: admin\n"

		nohup $EAP_HOME/bin/standalone.sh > eap.log &
		printf "\n EAP starting... check http://localhost:8180/auth/admin/"
		printf "\n\t User: admin"
		printf "\n\t Pass: admin\n"
		;;
	eap-logs)
		tail -f eap.log
		;; 
	sso-logs)
		tail -f sso.log
		;;
	deploy)
		deployQuickstarts
		importQuickstartsInKeycloak
		;;
	*)
		echo $"Usage: $0  install | uninstall | start | eap-logs | sso-logs"
		exit 1

esac
