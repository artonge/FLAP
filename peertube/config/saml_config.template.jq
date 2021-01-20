{
	"auth-display-name": "FLAP SSO ($PRIMARY_DOMAIN_NAME)",
	"sign-get-request": "true",
	"login-url": "https://auth.$PRIMARY_DOMAIN_NAME/saml/singleSignOn",
	"logout-url": "https://auth.$PRIMARY_DOMAIN_NAME/saml/singleLogout",
	"provider-certificate": $provider_cert,
	"service-certificate": $service_cert,
	"service-private-key": $service_priv_key,
	"username-property": "uid",
	"mail-property": "mail",
	"display-name-property": "cn",
	"role-property": "peertube_role"
}
