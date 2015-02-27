#!/bin/bash
cd /tmp
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar xvfz ioncube_loaders_lin_x86-64.tar.gz
php_extension_dir="$(php -i | grep "extension_dir => /usr" | grep -P '\/usr\/lib\/[\S]*(?= => )' -o)"
ioncube_dir="$php_extension_dir"
mkdir -p "$ioncube_dir"
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
mv ./ioncube/ioncube_loader_lin_${PHP_VERSION}*.so $ioncube_dir
chmod 644 $ioncube_dir/ioncube_loader_lin_5*.so
chown root:root $ioncube_dir/ioncube_loader_lin_5*.so
rm -rf ./ioncube
rm -rf ioncube_loaders_lin_x86-64.tar.gz
