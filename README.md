# Red Hat Single Sign on (aka Keycloak) Demo

## Product Introduction

Usually, I use this presentation (PTBR) that I forked from [github.com/rafaeltuelho](@rafaeltuelho) to introduct Keycloak: http://redhat.slides.com/rdasilva/rh-sso-keycloak?token=gPXwtPW_

## Requirements

* [EAP 7 binary](https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=55301) - jboss-eap-7.1.0.zip 
* [RH SSO 7.1 binary](https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=50621) - rh-sso-7.1.0.zip
* [EAP 7 OpenID adapter](https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=50601) - rh-sso-7.1.0-eap7-adapter.zip
* [EAP 7 SAML adapter](https://access.redhat.com/jbossnetwork/restricted/softwareDownload.html?softwareId=50551) - rh-sso-7.1.0-saml-eap7-adapter.zip

## Setup

First you need to adjust the [setup-env.var](setup-env.sh) file with your own values.

### Install

    ./setup.sh install

### Start 

    ./setup.sh start

Follow the logs (Optional),

    ./setup.sh eap-logs
    ./setup.sh sso-logs

[RH-SSO Admin console: http://localhost:8180/auth](http://localhost:8180/auth)

### Deploy

This phase, deploy 3 quickstarts in EAP to demonstrate a single sign on using OpenId. It import those applications in RHSSO as clients. 

[Quickstarts](https://github.com/redhat-developer/redhat-sso-quickstarts) deployed: 

* [service-jee-jaxrs](https://github.com/redhat-developer/redhat-sso-quickstarts/tree/7.1.x/service-jee-jaxrs)
* [app-profile-jee-html5](https://github.com/redhat-developer/redhat-sso-quickstarts/tree/7.1.x/app-profile-jee-html5)
* [app-jee-jsp](https://github.com/redhat-developer/redhat-sso-quickstarts/tree/7.1.x/app-jee-jsp)

To deploy, run: 

    ./setup.sh deploy

Once deployed, you can navigate and show the mainly SSO features.

You need to configure the user and roles as described in the [quickstarts doc](https://github.com/redhat-developer/redhat-sso-quickstarts#create-roles-and-user).

Now, you can navigate in the applications: 

* http://localhost:8080/app-profile-html5/

* http://localhost:8080/app-jsp




