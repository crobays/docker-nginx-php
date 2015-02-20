# Run NGINX in a container with PHP-FPM on top of [phusion/baseimage](https://github.com/phusion/baseimage-docker)

	docker build \
		 --name crobays/nginx-php\
		 .

	docker run \
		-v ./:/project \
		-e PUBLIC_PATH: /project/public \
		-e TIMEZONE: Europe/Amsterdam \
		 crobays/nginx-php
