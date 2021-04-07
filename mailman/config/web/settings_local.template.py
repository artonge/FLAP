# Change indexing engine.
# https://github.com/maxking/docker-mailman/blob/master/README.md#setting-up-search-indexing
HAYSTACK_CONNECTIONS = {
    'default': {
        'ENGINE': 'xapian_backend.XapianEngine',
        'PATH': "/opt/mailman-web-data/fulltext_index",
    },
}


# Disable social login.
INSTALLED_APPS = [
    'hyperkitty',
    'postorius',
    'django_mailman3',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'django_gravatar',
    'compressor',
    'haystack',
    'django_extensions',
    'django_q',
    'allauth',
    'allauth.account',
    'allauth.socialaccount',
]


# Change "From:" e-mail address
DEFAULT_FROM_EMAIL="admin@$PRIMARY_DOMAIN_NAME"


# LDAP Auth.
import ldap
from django_auth_ldap.config import LDAPSearch, LDAPSearchUnion

AUTHENTICATION_BACKENDS = (
    'django_auth_ldap.backend.LDAPBackend',
    'django.contrib.auth.backends.ModelBackend',
    'allauth.account.auth_backends.AuthenticationBackend',
)

AUTH_LDAP_SERVER_URI = "ldap://ldap"
AUTH_LDAP_BIND_DN = "cn=admin,dc=flap,dc=local"
AUTH_LDAP_BIND_PASSWORD = "$ADMIN_PWD"
AUTH_LDAP_START_TLS = False

AUTH_LDAP_USER_ATTR_MAP = {"username": "uid", "first_name": "cn", "email": "mail"}
AUTH_LDAP_USER_SEARCH = LDAPSearch("ou=users,dc=flap,dc=local", ldap.SCOPE_SUBTREE, "(uid=%(user)s)")

ACCOUNT_EMAIL_VERIFICATION = 'none'

# Debug
DEBUG = False
