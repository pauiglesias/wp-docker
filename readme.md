# WP Docker

Domain used for testing: wp-docker-test.local

## Docker Commands

docker-compose -f docker-compose_dev.yml up -d

docker-compose -f docker-compose_dev.yml logs -t

docker-compose -f docker-compose_dev.yml down

docker exec -it [container id] /bin/bash

## Nginx

Copy .env_dev_sample to .env_dev and set the development domain.

## Linux permissions

sudo chown -R www-data:[my-user] wordpress/src

sudo chmod -R 775 wordpress/src

## Config files

wordpress/src/wp-config.php and/or

wordpress/src/wp-config-docker.php (for docker image)

define('WP_HOME', 'https://wp-docker-test.local');

define('WP_SITEURL', 'https://wp-docker-test.local');

define('FS_METHOD', 'direct');

## .htaccess

    <IfModule mod_rewrite.c>

        <IfModule mod_negotiation.c>
            Options -MultiViews -Indexes
        </IfModule>

        RewriteEngine On

        # www redirect local
        RewriteCond %{HTTP_HOST} ^www.wp-docker-test.local$ [NC]
        RewriteRule ^ http://wp-docker-test.local%{REQUEST_URI} [R=301,L]

        # www redirect live
        RewriteCond %{HTTP_HOST} ^www.mydomain.com$ [NC]
        RewriteRule ^ https://mydomain.com%{REQUEST_URI} [R=301,L]

        # https redirect
        RewriteCond %{HTTPS} off
        RewriteCond %{HTTP_HOST} !.local$ [NC]
        RewriteCond %{HTTP_HOST} ^www\.(.*)$ [NC]
        RewriteRule ^(.*)$ https://%1/$1 [R=301,L]

        # https redirect
        RewriteCond %{HTTPS} off
        RewriteCond %{HTTP_HOST} !.local$ [NC]
        RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

    </IfModule>

## hosts file

127.0.0.[number] wp-docker-test.local www.wp-docker-test.local
