## The base system alterations

---

#### Todos

-   [ ] Send mail on user creation
-   [x] Prevent ssh key validation during git clone
-   [ ] Test base install script
-   [ ] Better update process
    -   [x] Base system update
    -   [x] FLAP update
    -   [ ] Detect when restart is necessary on update
    -   [x] Individual services update
-   [ ] Handle multiple domain name
-   [ ] Handle certificates renewal
-   [x] Generate cron based on each services or install one cron that will execute services cron
-   [ ] Which email to use during certs generation ?
-   [x] Setup recursive tasks for cert generation
-   [ ] Ask for static IP to the gateway
-   [ ] Handle WANPPPConnection (orange livebox pro)
-   [x] Detect when a reboot is required after an update
-   [ ] Create a docker-compose proxy in manager cli to avoid path errors
