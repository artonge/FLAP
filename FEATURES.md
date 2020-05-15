# Features & Roadmap

This is the list of FLAP's current and future features.

Future features are not limited to the one listed bellow.

Pull requests are welcome. See [contribution guidlines](https://gitlab.com/flap-box/flap/-/blob/master/CONTRIBUTING.md).

**Priority mark:**

-   [<span style="color: red; font-size: 20px; line-height: 12px">•</span>] Will add in less than 6 months.
-   [<span style="color: orange; font-size: 20px; line-height: 12px">•</span>] Will add in less than 1 year.
-   [<span style="color: yellow; font-size: 20px; line-height: 12px">•</span>] Will add one day.
-   [<span style="color: blue; font-size: 20px; line-height: 12px">•</span>] Won't add, but pull requests are welcome.

### **Services framework**

[Detailed list of framework features for services](https://gitlab.com/flap-box/flap/-/blob/master/README.services.md)

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
    -   [ ] More RAID setups [<span style="color: blue; font-size: 20px; line-height: 12px">•</span>]
-   [ ] Backup management [<span style="color: orange; font-size: 20px; line-height: 12px">•</span>]
-   [ ] Monitoring tool [<span style="color: yellow; font-size: 20px; line-height: 12px">•</span>]

### **Applications**

-   [x] **FLAP's web GUI**
-   [x] **Nextcloud**
    -   [x] OnlyOffice
-   [x] **SOGo**
-   [x] **Synapse/Riot**
    -   [x] Automatic room join for new users
-   [x] **Jitsi**
    -   [ ] Limit access to FLAP's users [<span style="color: yellow; font-size: 20px; line-height: 12px">•</span>]
-   [ ] **Weblate** [<span style="color: orange; font-size: 20px; line-height: 12px">•</span>]
-   [ ] **Ghost** [<span style="color: orange; font-size: 20px; line-height: 12px">•</span>]
-   [ ] **Mattermost** [<span style="color: orange; font-size: 20px; line-height: 12px">•</span>]
-   [ ] **Peertube** [<span style="color: orange; font-size: 20px; line-height: 12px">•</span>]
-   [ ] **Home Assistant** [<span style="color: yellow; font-size: 20px; line-height: 12px">•</span>]

### **Backend services**

-   [x] **Nginx**
    -   [x] TLS
    -   [x] HTTP2
-   [x] **LemonLDAP**
    -   [x] SSO
        -   [x] HTTP Headers
        -   [x] SAML
        -   [ ] CAS [<span style="color: yellow; font-size: 20px; line-height: 12px">•</span>]
    -   [ ] OpenID server [<span style="color: yellow; font-size: 20px; line-height: 12px">•</span>]
    -   [ ] External authentication provider [<span style="color: yellow; font-size: 20px; line-height: 12px">•</span>]
    -   [ ] Multiple factor authentication [<span style="color: orange; font-size: 20px; line-height: 12px">•</span>]
-   [x] **OpenLDAP**
-   [x] **PostgreSQL**
-   [ ] **MySQL** [<span style="color: yellow; font-size: 20px; line-height: 12px">•</span>]
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
    -   [ ] ClamAV [<span style="color: orange; font-size: 20px; line-height: 12px">•</span>]
-   [ ] **Wireguard** [<span style="color: yellow; font-size: 20px; line-height: 12px">•</span>]
    -   [ ] To access services [<span style="color: yellow; font-size: 20px; line-height: 12px">•</span>]
    -   [ ] Automatic connection [<span style="color: yellow; font-size: 20px; line-height: 12px">•</span>]

### **Cross services features**

-   [x] **Users management**
    -   [x] Create, delete and list users in FLAP's GUI
    -   [x] Allow self registration in auth portal
    -   [ ] Allow user to set a profile picture
    -   [ ] Bulk add in FLAP's GUI [<span style="color: red; font-size: 20px; line-height: 12px">•</span>]
    -   [ ] Groups [<span style="color: red; font-size: 20px; line-height: 12px">•</span>]
        -   [ ] Limit services access during SSO [<span style="color: red; font-size: 20px; line-height: 12px">•</span>]
        -   [ ] Use default group for self registered users [<span style="color: red; font-size: 20px; line-height: 12px">•</span>]
        -   [ ] Create mailing list [<span style="color: orange; font-size: 20px; line-height: 12px">•</span>]
-   [x] **Domains management**

    -   [x] Add, delete and update a domain in FLAP's GUI
    -   [x] Services configuration after domain update
    -   [x] Automatic TLS setup with Letsencrypt
    -   [x] Automatic Nginx setup by domain
    -   [x] Self signed certificate setup
        -   [ ] GUI to download the root CA [<span style="color: yellow; font-size: 20px; line-height: 12px">•</span>]
    -   [x] DKIM generation
    -   [ ] Automatic DNS configuration
        -   [x] FLAP.id
        -   [ ] NameCheap [<span style="color: blue; font-size: 20px; line-height: 12px">•</span>]
        -   [ ] DuckDns [<span style="color: blue; font-size: 20px; line-height: 12px">•</span>]

-   [x] **Services management**
    -   [x] Features flags
    -   [x] Documentation for how to use a service
    -   [ ] GUI to enable/disable flags [<span style="color: yellow; font-size: 20px; line-height: 12px">•</span>]
    -   [ ] Enable/Disable services [<span style="color: yellow; font-size: 20px; line-height: 12px">•</span>]
    -   [ ] Disk usage per services [<span style="color: yellow; font-size: 20px; line-height: 12px">•</span>]
    -   [ ] GUI to restart the services [<span style="color: orange; font-size: 20px; line-height: 12px">•</span>]
    -   [ ] GUI to restart the host [<span style="color: orange; font-size: 20px; line-height: 12px">•</span>]
