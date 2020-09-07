FROM ubuntu:20.04


ADD . /app
WORKDIR /app
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install php composer nodejs npm curl wkhtmltopdf/focal -y \
    && composer update 


EXPOSE 9999

CMD php -S0.0.0.0:$PORT -t public public/index.php
