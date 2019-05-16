-- SOGO
CREATE USER sogo WITH ENCRYPTED PASSWORD '$SOGO_DB_PWD' CREATEDB;
CREATE DATABASE sogo WITH OWNER sogo;

-- Nextcloud
CREATE USER nextcloud WITH ENCRYPTED PASSWORD '$NEXTCLOUD_DB_PWD' CREATEDB;
CREATE DATABASE nextcloud WITH OWNER sogo;
