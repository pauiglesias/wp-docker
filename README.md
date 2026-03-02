# WP Docker

Domain used for testing: wp-docker.local

## Docker Commands

./docker_up.sh env/myenv.env

docker compose --env-file=env/myenv.env logs -t

docker compose --env-file=env/myenv.env down

docker exec -it [container id] /bin/bash

docker stats --no-stream

## MySQL

Create a ../data/mysql directory to avoid volume lost

## Nginx

Copy env/_sample.env to a new .env file in the env/ directory and set the development domain.

## Linux permissions

sudo chown -R www-data:[my-user] wordpress/src

sudo chmod -R 775 wordpress/src

## Config files

wordpress/src/wp-config.php and/or

wordpress/src/wp-config-docker.php (for docker image)

define('WP_HOME', 'https://wp-docker.local');
define('WP_SITEURL', 'https://wp-docker.local');
define('FS_METHOD', 'direct');

## .htaccess

    <IfModule mod_rewrite.c>

        <IfModule mod_negotiation.c>
            Options -MultiViews -Indexes
        </IfModule>

        RewriteEngine On

        # www redirect local
        RewriteCond %{HTTP_HOST} ^www.wp-docker.local$ [NC]
        RewriteRule ^ http://wp-docker.local%{REQUEST_URI} [R=301,L]

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

127.0.0.[number] wp-docker.local www.wp-docker.local
