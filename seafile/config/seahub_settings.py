# MEMCACHED
CACHES = {
    'default': {
        'BACKEND': 'django_pylibmc.memcached.PyLibMCCache',
        'LOCATION': 'memcached:11211',
    },
    'locmem': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
    },
}
COMPRESS_CACHE_BACKEND = 'locmem'

# SEAFILE URL
FILE_SERVER_ROOT = 'http://files.flap.localhost/seafhttp'

# SSO
TRUST_PROXY_AUTHTENTICATION = True

# USER CONFIG
ENABLE_DELETE_ACCOUNT = False
ENABLE_UPDATE_USER_INFO = False
