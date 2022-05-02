# Docker Commands
docker-compose -f docker-compose_dev.yml up -d
docker-compose -f docker-compose_dev.yml logs -t
docker-compose -f docker-compose_dev.yml down

# Ubuntu firewall
ufw allow in to 172.17.0.0/16 proto tcp port 6000
ufw allow in to 172.17.0.0/16 proto tcp port 6001

# Linux permissions
sudo chown -R www-data:[my-user] wordpress/
sudo chmod -R 775 wordpress/

# wp-config.php
define('WP_HOME', 'http://wp-docker-test.local');  
define('WP_SITEURL', 'http://wp-docker-test.local');