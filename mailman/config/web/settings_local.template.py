# https://github.com/maxking/docker-mailman/blob/master/README.md#setting-up-search-indexing
HAYSTACK_CONNECTIONS = {
    'default': {
        'ENGINE': 'xapian_backend.XapianEngine',
        'PATH': "/opt/mailman-web-data/fulltext_index",
    },
}

# Disable social login.
MAILMAN_WEB_SOCIAL_AUTH = []

# LDAP Auth.
import ldap
from django_auth_ldap.config import LDAPSearch, LDAPSearchUnion


AUTHENTICATION_BACKENDS = (
    'django.contrib.auth.backends.ModelBackend',
    'allauth.account.auth_backends.AuthenticationBackend',
    'django_auth_ldap.backend.LDAPBackend',
)

AUTH_LDAP_SERVER_URI = "ldap"
AUTH_LDAP_BIND_DN = "cn=admin,dc=flap,dc=local"
AUTH_LDAP_BIND_PASSWORD = "$ADMIN_PWD"
AUTH_LDAP_START_TLS = False

AUTH_LDAP_USER_ATTR_MAP = {"username": "uid", "first_name": "cn", "email": "mail"}
AUTH_LDAP_USER_SEARCH = LDAPSearch("ou=users,dc=flap,dc=local ", ldap.SCOPE_SUBTREE, "(uid=%(user)s)")

AUTH_LDAP_USER_FLAGS_BY_GROUP = {
    "is_superuser": "organizationalPerson"
}

DEBUG = True
