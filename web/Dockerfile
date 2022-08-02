
FROM ubuntu:latest

# Install core components
ENV DEBIAN_FRONTEND noninteractive

RUN apt update && \
    apt upgrade -y && \
    apt install -y software-properties-common && \
    apt install -y mysql-server sudo wget curl gcc git gnupg-agent locales

RUN locale-gen en_US.UTF-8 && \
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale
ENV LANG en_US.UTF-8

RUN useradd misp && usermod -aG sudo misp

# Install script
COPY --chown=misp:misp INSTALL.sh* ./
RUN chmod +x INSTALL.sh
RUN echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER misp

RUN bash INSTALL.sh -A -u

USER root

# Supervisord Setup

RUN apt -y install supervisor

RUN sudo -u www-data php /var/www/MISP/app/composer.phar require --with-all-dependencies supervisorphp/supervisor \
    guzzlehttp/guzzle \
    php-http/message \
    lstrojny/fxmlrpc

RUN ( \
    echo ''; \
    echo '[inet_http_server]'; \
    echo 'port=127.0.0.1:9001'; \
    echo 'username=supervisor'; \
    echo 'password=PWD_CHANGE_ME'; \
    ) >> /etc/supervisor/supervisord.conf

RUN ( \
    echo '[group:misp-workers]'; \
    echo 'programs=default,email,cache,prio,update'; \
    echo ''; \
    echo '[program:default]'; \
    echo 'directory=/var/www/MISP'; \
    echo 'command=/var/www/MISP/app/Console/cake start_worker default'; \
    echo 'process_name=%(program_name)s_%(process_num)02d'; \
    echo 'numprocs=5'; \
    echo 'autostart=true'; \
    echo 'autorestart=true'; \
    echo 'redirect_stderr=false'; \
    echo 'stderr_logfile=/var/www/MISP/app/tmp/logs/misp-workers-errors.log'; \
    echo 'stdout_logfile=/var/www/MISP/app/tmp/logs/misp-workers.log'; \
    echo 'directory=/var/www/MISP'; \
    echo 'user=www-data'; \
    echo ''; \
    echo '[program:prio]'; \
    echo 'directory=/var/www/MISP'; \
    echo 'command=/var/www/MISP/app/Console/cake start_worker prio'; \
    echo 'process_name=%(program_name)s_%(process_num)02d'; \
    echo 'numprocs=5'; \
    echo 'autostart=true'; \
    echo 'autorestart=true'; \
    echo 'redirect_stderr=false'; \
    echo 'stderr_logfile=/var/www/MISP/app/tmp/logs/misp-workers-errors.log'; \
    echo 'stdout_logfile=/var/www/MISP/app/tmp/logs/misp-workers.log'; \
    echo 'directory=/var/www/MISP'; \
    echo 'user=www-data'; \
    echo ''; \
    echo '[program:email]'; \
    echo 'directory=/var/www/MISP'; \
    echo 'command=/var/www/MISP/app/Console/cake start_worker email'; \
    echo 'process_name=%(program_name)s_%(process_num)02d'; \
    echo 'numprocs=5'; \
    echo 'autostart=true'; \
    echo 'autorestart=true'; \
    echo 'redirect_stderr=false'; \
    echo 'stderr_logfile=/var/www/MISP/app/tmp/logs/misp-workers-errors.log'; \
    echo 'stdout_logfile=/var/www/MISP/app/tmp/logs/misp-workers.log'; \
    echo 'directory=/var/www/MISP'; \
    echo 'user=www-data'; \
    echo ''; \
    echo '[program:update]'; \
    echo 'directory=/var/www/MISP'; \
    echo 'command=/var/www/MISP/app/Console/cake start_worker update'; \
    echo 'process_name=%(program_name)s_%(process_num)02d'; \
    echo 'numprocs=1'; \
    echo 'autostart=true'; \
    echo 'autorestart=true'; \
    echo 'redirect_stderr=false'; \
    echo 'stderr_logfile=/var/www/MISP/app/tmp/logs/misp-workers-errors.log'; \
    echo 'stdout_logfile=/var/www/MISP/app/tmp/logs/misp-workers.log'; \
    echo 'directory=/var/www/MISP'; \
    echo 'user=www-data'; \
    echo ''; \
    echo '[program:cache]'; \
    echo 'directory=/var/www/MISP'; \
    echo 'command=/var/www/MISP/app/Console/cake start_worker cache'; \
    echo 'process_name=%(program_name)s_%(process_num)02d'; \
    echo 'numprocs=5'; \
    echo 'autostart=true'; \
    echo 'autorestart=true'; \
    echo 'redirect_stderr=false'; \
    echo 'stderr_logfile=/var/www/MISP/app/tmp/logs/misp-workers-errors.log'; \
    echo 'stdout_logfile=/var/www/MISP/app/tmp/logs/misp-workers.log'; \
    echo 'user=www-data'; \
    ) > /etc/supervisor/conf.d/supervisord.conf


RUN service supervisor stop
RUN service supervisor start

# Make a backup of /var/www/MISP to restore it to the local moint point at first boot
WORKDIR /var/www/MISP
RUN tar czpf /root/MISP.tgz .

VOLUME /var/www/MISP
EXPOSE 80
EXPOSE 443
EXPOSE 3306
EXPOSE 6666

RUN /var/www/MISP/app/Console/cake Admin setSetting "MISP.python_bin" "/var/www/MISP/venv/bin/python"
RUN /var/www/MISP/app/Console/cake live 1
RUN chown www-data:www-data /var/www/MISP/app/Config/config.php*

ENTRYPOINT ["/bin/bash"]
