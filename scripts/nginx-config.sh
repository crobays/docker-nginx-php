#!/bin/bash
PUBLIC_PATH="${PUBLIC_PATH:-/project/public}"

mkdir -p "$PUBLIC_PATH"

if [ ! -f "$PUBLIC_PATH/index.php" ]
then
	echo "<h1>You made it!</h1><p>$PUBLIC_PATH</p><pre><?php print_r(\$_SERVER);?></pre>" > "$PUBLIC_PATH/index.php"
fi

echo "daemon off;" >> /etc/nginx/nginx.conf

rm -rf /var/log/nginx
mkdir /var/log/nginx

if [ -f "/project/nginx.conf" ]
then
	ln -sf "/project/nginx.conf" /etc/nginx/nginx.conf
fi

file="/conf/nginx-virtual.conf"
if [ -f "/project/$NGINX_CONF" ]
then
	file="/project/$NGINX_CONF"
fi
rm -rf /etc/nginx/sites-enabled/*
cp -f "$file" /etc/nginx/sites-enabled/virtual.conf

sed -i "s/root \/project\/public;/root ${PUBLIC_PATH//\//\\\/};/" /etc/nginx/sites-enabled/virtual.conf

echo "PUBLIC_PATH: $PUBLIC_PATH"
