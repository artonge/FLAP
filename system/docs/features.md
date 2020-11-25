# Features & Roadmap

This is the list of FLAP's current and future features.

Future features are not limited to the one listed bellow.

Pull requests are welcome. See [contribution guidlines](contributing.md).

**Priority mark:**

-   [⚫ ⚫ ⚫] Will add in less than 6 months.
-   [⚫ ⚫] Will add in less than 1 year.
-   [⚫] Will add one day.
-   [⚪] Won't add, but pull requests are welcome.

### **Framework's features for services**

[Detailed list of framework features for services](create_new_service.md)

-   [x] **Hooks** called during FLAP life-cycle

    -   [x] Database initialization
    -   [x] Pre/post installation
    -   [x] Moad service's specific environment global variables
    -   [x] Configuration generation before starting services
    -   [x] Wait ready after starting services
    -   [x] Post FLAP update
    -   [x] Post domain update

-   [x] **Configuration file** with **templates** for:

    -   [x] The service
    -   [x] Docker-compose
    -   [x] Nginx
    -   [x] LemonLDAP (SSO)

-   [x] **Migrations** run after a FLAP update when services are stopped.

-   [x] **Dockerfile** to automatically build custom docker images in Gitlab pipelines

-   [x] **Cron** tasks

### **Host system management**

-   [x] Automatic system package update
-   [x] Automatic FLAP update
-   [x] System's mails forwarded to an admin email
-   [x] HD management
    -   [x] single disk setup
    -   [x] RAID1 setup
    -   [ ] More RAID setups [⚪]
-   [x] Backup data and configuration
-   [x] Monitoring services and host server

### **Applications**

-   [x] **FLAP's web GUI**
-   [x] **Nextcloud**
    -   [x] OnlyOffice
-   [x] **SOGo**
-   [x] **Synapse/Element**
    -   [x] Automatic room join for new users
-   [x] **Jitsi**
    -   [ ] Limit access to FLAP's users [⚫]
-   [x] **Matomo**
-   [x] **Peertube**
-   [ ] **Ghost** [⚫]
-   [ ] **Miniflux** [⚫]
-   [ ] **Weblate** [⚫ ⚫]
-   [ ] **Mattermost** [⚫ ⚫]
-   [ ] **Discourse** [⚫ ⚫]
-   [ ] **Home Assistant** [⚫]

### **Backend services**

-   [x] **Nginx**
    -   [x] TLS
    -   [x] HTTP2
-   [x] **LemonLDAP**
    -   [x] SSO
        -   [x] HTTP Headers
        -   [x] SAML
        -   [ ] CAS [⚫]
    -   [ ] OpenID server [⚫]
    -   [ ] External authentication provider [⚫]
    -   [ ] Multiple factor authentication [⚫ ⚫]
-   [x] **OpenLDAP**
-   [x] **PostgreSQL**
-   [ ] **MySQL** [⚫]
-   [x] **Redis**
-   [x] **Memcached**
-   [x] **Mail**
    -   [x] Dovecot
    -   [x] Postfix
    -   [x] Postgrey
    -   [x] Postscreen
    -   [x] Amavis
    -   [x] SmapAssassin
    -   [x] OpenDKIM
    -   [x] OpenDMARC
    -   [ ] ClamAV [⚫ ⚫]
-   [ ] **Wireguard** [⚫]
    -   [ ] To access services inside a VPN [⚫]
        -   [ ] SSO [⚫]
    -   [ ] To publish services from another server/IP [⚫]

### **Cross services features**

-   [x] **Users management**
    -   [x] Create, delete and list users in FLAP's GUI
    -   [x] Allow self registration in auth portal
    -   [ ] Allow user to set a profile picture
    -   [ ] Bulk add in FLAP's GUI [⚫ ⚫ ⚫]
    -   [ ] Groups [⚫ ⚫ ⚫]
        -   [ ] Limit services access during SSO [⚫ ⚫ ⚫]
        -   [ ] Use default group for self registered users [⚫ ⚫ ⚫]
        -   [ ] Create mailing list [⚫ ⚫]
-   [x] **Domains management**

    -   [x] Add, delete and update a domain in FLAP's GUI
    -   [x] Services configuration after domain update
    -   [x] Automatic TLS setup with Letsencrypt
    -   [x] Automatic Nginx setup by domain
    -   [x] Self signed certificate setup
        -   [ ] GUI to download the root CA [⚫]
    -   [x] DKIM generation
    -   [ ] Automatic DNS configuration
        -   [x] FLAP.id
        -   [ ] NameCheap [⚪]
        -   [ ] DuckDns [⚪]

-   [x] **Services management**
    -   [x] Features flags
    -   [x] Documentation for how to use a service
    -   [x] GUI to enable/disable flags
	-   [x] GUI to restart the services
	-   [x] GUI to restart the host
    -   [ ] Enable/Disable services [⚫]
    -   [ ] Disk usage per services [⚫]
