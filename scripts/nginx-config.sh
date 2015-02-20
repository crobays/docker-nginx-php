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

php_code="echo '('.(array_key_exists('DOMAIN',\$_SERVER) ? str_replace('.', '\\\\\.', implode('|', array_unique(array_map(function(\$domain){\$d = array_reverse(explode('.', \$domain)); return \$d[1].'.'.\$d[0];}, in_array(substr(\$_SERVER['DOMAIN'], 0, 1), array('[', '{')) ? json_decode(str_replace(\"'\", '\"', \$_SERVER['DOMAIN']), 1) : array(\$_SERVER['DOMAIN']))))) : '').')';"
domain="$(php -r "$php_code")"

if [ "$domain" == "()" ]
then
	php_code="file_put_contents('/etc/nginx/sites-enabled/virtual.conf', preg_replace('/# == add header ==(.|\n)*# == add header ==/', '', file_get_contents('/etc/nginx/sites-enabled/virtual.conf')));"
	php -r "$php_code"
else
	sed -i "s/example\\\.com/$domain/" /etc/nginx/sites-enabled/virtual.conf
fi

echo "PUBLIC_PATH: $PUBLIC_PATH"
