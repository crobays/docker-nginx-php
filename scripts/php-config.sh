#!/bin/bash

function find_replace_add_string_to_file() {
    find="$1"
    replace="$2"
    replace_escaped="${2//\//\\/}"
    file="$3"
    label="$4"
    if grep -q ";$find" "$file" # The exit status is 0 (true) if the name was found, 1 (false) if not
    then
        action="Uncommented"
        sed -i "s/;$find/$replace_escaped/" "$file"
    elif grep -q "#$find" "$file" # The exit status is 0 (true) if the name was found, 1 (false) if not
    then
        action="Uncommented"
        sed -i "s/#$find/$replace_escaped/" "$file"
    elif grep -q "$replace" "$file"
    then
        action="Already set"
    elif grep -q "$find" "$file"
    then
        action="Overwritten"
        sed -i "s/$find/$replace_escaped/" "$file"
    else
        action="Added"
        echo -e "\n$replace\n" >> "$file"
    fi
    echo " ==> Setting $label ($action) [$replace in $file]"
}

php5enmod mcrypt

if [ "$TIMEZONE" != "" ]
then
	find_replace_add_string_to_file "date.timezone =.*" "date.timezone = $TIMEZONE" /etc/php5/fpm/php.ini "PHP timezone"
else
	echo " ==> Timezone not set (not given TIMEZONE)"
fi

find_replace_add_string_to_file "daemonize =.*" "daemonize = no" /etc/php5/fpm/php-fpm.conf "PHP daemon off"
find_replace_add_string_to_file "daemonize =.*" "daemonize = no" /etc/php5/cli/php.ini "PHP daemon off"

if [ "${ENVIRONMENT:0:4}" != "prod" ]
then
	find_replace_add_string_to_file "display_errors =.*" "display_errors = On" /etc/php5/fpm/php.ini "PHP display errors on"
	find_replace_add_string_to_file "display_startup_errors =.*" "display_startup_errors = On" /etc/php5/fpm/php.ini "PHP display startup errors on"
	find_replace_add_string_to_file "display_startup_errors =.*" "display_startup_errors = On" /etc/php5/cli/php.ini "PHP display startup errors on"
fi

find_replace_add_string_to_file "enable_dl = .*" "enable_dl = On" /etc/php5/fpm/php.ini "PHP enable dl on"
find_replace_add_string_to_file "enable_dl = .*" "enable_dl = On" /etc/php5/cli/php.ini "PHP enable dl on"

# Disable default mimetype
# find_replace_add_string_to_file "default_mimetype =.*" "default_mimetype = \"\"" /etc/php5/fpm/php.ini "PHP default mimetype none"
# find_replace_add_string_to_file "default_mimetype =.*/default_mimetype = \"\"" /etc/php5/cli/php.ini "PHP "

#find_replace_add_string_to_file ";listen.owner =.*" "listen.owner = nginx" /etc/php5/fpm/pool.d/www.conf "PHP owner to nginx"
#find_replace_add_string_to_file ";listen.group =.*" "listen.group = nginx" /etc/php5/fpm/pool.d/www.conf "PHP group to nginx"
#find_replace_add_string_to_file ";listen.mode =.*" "listen.mode = 0660" /etc/php5/fpm/pool.d/www.conf "PHP owner to 0660"

if [ -f "/project/php-fpm.ini" ]
then
	ln -sf "/project/php-fpm.ini" /etc/php5/fpm/php.ini
fi

if [ -f "/project/php-cli.ini" ]
then
	ln -sf "/project/php-cli.ini" /etc/php5/cli/php.ini
fi

if [ -f "/project/php-fpm.conf" ]
then
	ln -sf "/project/php-fpm.conf" /etc/php5/fpm/pool.d/php-fpm.conf
fi

if [ -f "/project/php-fpm-www.conf" ]
then
	cp -f "/project/php-fpm-www.conf" /etc/php5/fpm/pool.d/www.conf
fi

while read -r e
do
	strlen="${#e}"
	if [ "${e:$strlen-1:1}" == "=" ] || [ "$e" == "${e/=/}" ] || [ $strlen -gt 100 ]
	then
		continue
	fi
	
	echo "env[${e/=/] = \"}\"" >> /etc/php5/fpm/pool.d/www.conf
done <<< "$(env)"

#chown nginx:nginx /var/run/php-fpm
