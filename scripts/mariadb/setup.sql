-- SEAFILE
CREATE USER 'seafile' IDENTIFIED BY 'seafile';

CREATE DATABASE `ccnet` CHARACTER SET = 'utf8';
CREATE DATABASE `seafile` CHARACTER SET = 'utf8';
CREATE DATABASE `seahub` CHARACTER SET = 'utf8';

GRANT ALL PRIVILEGES ON `ccnet`.* TO `seafile`;
GRANT ALL PRIVILEGES ON `seafile`.* TO `seafile`;
GRANT ALL PRIVILEGES ON `seahub`.* TO `seafile`;
