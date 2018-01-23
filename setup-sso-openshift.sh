oc project sso
oc secrets new sso-ssl-secret server.keystore
oc secrets new sso-jgroups-secret jgroups.keystore

oc create serviceaccount sso
oc policy add-role-to-user view system:serviceaccount:sso:sso -n sso
oc secrets link sso sso-ssl-secret sso-jgroups-secret

oc process sso71-postgresql-persistent --param-file=rh-sso-template.env -n openshift | oc create -n sso -f -
