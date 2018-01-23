oc project sso
oc create -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/secrets/eap7-app-secret.json
oc process eap70-sso-s2i --param-file=eap-sso-template.env -n openshift | oc create -n sso -f -
