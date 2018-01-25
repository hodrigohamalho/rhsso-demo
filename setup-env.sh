# Allow point to dir where installers are.
TARGET_DIR=./install
BINARIES_DIR=/Users/rramalho/bin

EAP_INSTALLER=$BINARIES_DIR/jboss-eap-7.1.0.zip
SSO_INSTALLER=$BINARIES_DIR/rh-sso-7.1.0.zip

EAP_HOME=$TARGET_DIR/jboss-eap-7.1
SSO_HOME=$TARGET_DIR/rh-sso-7.1

EAP_SSO_ADAPTER=$BINARIES_DIR/rh-sso-7.1.0-eap7-adapter.zip
EAP_SSO_SAML_ADAPTER=$BINARIES_DIR/rh-sso-7.1.0-saml-eap7-adapter.zip

# It may take more time depending your machine configurations
JBOSS_STARTUP_TIME=5

VERSION="EAP 7.0 | SSO 7.1"
