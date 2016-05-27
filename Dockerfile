FROM python:2.7

# Nginx installation

ENV NGINX_VERSION 1.10.0-1~jessie

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
	&& echo "deb http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
						ca-certificates \
						nginx=${NGINX_VERSION} \
						nginx-module-xslt \
						nginx-module-geoip \
						nginx-module-image-filter \
						nginx-module-perl \
						nginx-module-njs \
						gettext-base \
	&& rm -rf /var/lib/apt/lists/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

# Django, supervisor and gunicorn installation
COPY ./requirements.txt /requirements.txt

COPY ./app /app

RUN pip install -r /requirements.txt

# Supervisor configuration
# RUN mkdir /etc/supervisor
# RUN echo_supervisord_conf > /etc/supervisor/supervisord.conf

# COPY ./config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
# RUN cat /etc/supervisor/supervisord.copy >> /etc/supervisor/supervisord.conf
# RUN rm /etc/supervisor/supervisord.copy

# Supervisor service run
RUN mkdir /var/log/supervisor
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
CMD ["supervisorctl", "start", "djangoapp"]