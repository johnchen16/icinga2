# Dockerfile for icinga2 with icingaweb2
# https://github.com/jjethwa/icinga2

FROM debian:buster

ENV APACHE2_HTTP=REDIRECT \
    ICINGA2_FEATURE_GRAPHITE=false \
    ICINGA2_FEATURE_GRAPHITE_HOST=graphite \
    ICINGA2_FEATURE_GRAPHITE_PORT=2003 \
    ICINGA2_FEATURE_GRAPHITE_URL=http://graphite \
    ICINGA2_FEATURE_GRAPHITE_SEND_THRESHOLDS="true" \
    ICINGA2_FEATURE_GRAPHITE_SEND_METADATA="false" \
    ICINGA2_USER_FULLNAME="Icinga2" \
    ICINGA2_FEATURE_DIRECTOR="true" \
    ICINGA2_FEATURE_DIRECTOR_KICKSTART="true" \
    ICINGA2_FEATURE_DIRECTOR_USER="icinga2-director" \
    MYSQL_ROOT_USER=root

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    apache2 \
    ca-certificates \
    curl \
    dnsutils \
    file \
    gcc \
    gcc-multilib \
    git \
    gnupg \
    libdbd-mysql-perl \
    libdigest-hmac-perl \
    libnet-snmp-perl \
    locales \
    lsb-release \
    mailutils \
    make \
    mariadb-client \
    mariadb-server \
    netbase \
    net-tools \
    openssh-client \
    openssl \
    patch \
    php-curl \
    php-ldap \
    php-mysql \
    php-mbstring \
    php-gd \
    php-gmp \
    postfix \
    procps \
    pwgen \
    rrdtool \
    snmp \
    msmtp \
    sudo \
    supervisor \
    unzip \
    vim \
    wget \
    && apt-get --purge remove exim4 exim4-base exim4-config exim4-daemon-light \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN export DEBIAN_FRONTEND=noninteractive \
    && curl -s https://packages.icinga.com/icinga.key \
    | apt-key add - \
    && echo "deb http://packages.icinga.org/debian icinga-$(lsb_release -cs) main" > /etc/apt/sources.list.d/icinga2.list \
    && echo "deb http://deb.debian.org/debian $(lsb_release -cs)-backports main" > /etc/apt/sources.list.d/$(lsb_release -cs)-backports.list \
    && apt-get update \
    && apt-get install -y --install-recommends \
    icinga2 \
    icinga2-ido-mysql \
    icingacli \
    icingaweb2 \
    icingaweb2-module-doc \
    icingaweb2-module-monitoring \
    monitoring-plugins \
    nagios-nrpe-plugin \
    nagios-plugins-contrib \
    nagios-snmp-plugins \
    libmonitoring-plugin-perl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG GITREF_MODGRAPHITE=master
ARG GITREF_MODAWS=master
ARG GITREF_REACTBUNDLE=v0.7.0
ARG GITREF_INCUBATOR=v0.5.0
ARG GITREF_IPL=v0.3.0

RUN mkdir -p /usr/local/share/icingaweb2/modules/ \
    # Icinga Director
    && mkdir -p /usr/local/share/icingaweb2/modules/director/ \
    && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-director/archive/v1.7.0.tar.gz" \
    | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/director --exclude=.gitignore -f - \
    # fix for https://github.com/Icinga/icingaweb2-module-director/issues/1993
    && sed -i 's/change_time TIMESTAMP NOT NULL,/change_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,/' \
    /usr/local/share/icingaweb2/modules/director/schema/mysql.sql \
    # Icingaweb2 Graphite
    && mkdir -p /usr/local/share/icingaweb2/modules/graphite \
    && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-graphite/archive/v1.1.0.tar.gz" \
    | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/graphite -f - \
    # Icingaweb2 AWS
    && mkdir -p /usr/local/share/icingaweb2/modules/aws \
    && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-aws/archive/v1.0.0.tar.gz" \
    | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/aws -f - \
    && wget -q --no-cookies "https://github.com/aws/aws-sdk-php/releases/download/2.8.30/aws.zip" \
    && unzip -d /usr/local/share/icingaweb2/modules/aws/library/vendor/aws aws.zip \
    && rm aws.zip \
    # Module Reactbundle
    && mkdir -p /usr/local/share/icingaweb2/modules/reactbundle/ \
    && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-reactbundle/archive/v0.7.0.tar.gz" \
    | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/reactbundle -f - \
    # Module Incubator
    && mkdir -p /usr/local/share/icingaweb2/modules/incubator/ \
    && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-incubator/archive/v0.5.0.tar.gz" \
    | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/incubator -f - \
    # Module Ipl
    && mkdir -p /usr/local/share/icingaweb2/modules/ipl/ \
    && wget -q --no-cookies -O - "https://github.com/Icinga/icingaweb2-module-ipl/archive/v0.3.0.tar.gz" \
    | tar xz --strip-components=1 --directory=/usr/local/share/icingaweb2/modules/ipl -f - \
    # Module x509
    && mkdir -p /usr/local/share/icingaweb2/modules/x509/ \
    && wget -q --no-cookies "https://github.com/Icinga/icingaweb2-module-x509/archive/v1.0.0.zip" \
    && unzip -d /usr/local/share/icingaweb2/modules/x509 v1.0.0.zip \
    && mv /usr/local/share/icingaweb2/modules/x509/icingaweb2-module-x509-1.0.0/* /usr/local/share/icingaweb2/modules/x509/ \
    && rm -rf /usr/local/share/icingaweb2/modules/x509/icingaweb2-module-x509-1.0.0/ \
    && true

ADD content/ /

# Final fixes
RUN true \
    && sed -i 's/vars\.os.*/vars.os = "Docker"/' /etc/icinga2/conf.d/hosts.conf \
    && mv /etc/icingaweb2/ /etc/icingaweb2.dist \
    && mv /etc/icinga2/ /etc/icinga2.dist \
    && mkdir -p /etc/icinga2 \
    && usermod -aG icingaweb2 www-data \
    && usermod -aG nagios www-data \
    && mkdir -p /var/log/icinga2 \
    && chmod 755 /var/log/icinga2 \
    && chown nagios:adm /var/log/icinga2 \
    && rm -rf \
    /var/lib/mysql/* \
    && chmod u+s,g+s \
    /bin/ping \
    /bin/ping6 \
    /usr/lib/nagios/plugins/check_icmp

# Compile and install pnp4nagios
RUN mkdir /root/pnp4nagios
COPY pnp4nagios-0.6.26 /root/pnp4nagios
RUN cd /root/pnp4nagios \
    && ./configure --with-rrdtool=/usr/bin/rrdtool --with-httpd-conf=/etc/apache2/conf-available \
    && make all \
    && make install \
    && make install-config \
    && make install-init \
    && make install-webconf \
    && cd /etc/apache2/conf-enabled \
    && ln -s ../conf-available/pnp4nagios.conf . 

# Fix PNP web ui breakage
#RUN apt install -yq diffutils
COPY data.php.patch /
RUN patch /usr/local/pnp4nagios/share/application/models/data.php data.php.patch
#COPY data.php.patched /usr/local/pnp4nagios/share/application/models/data.php

# Fix Apache2 permission for /pnp4nagios for public access at this time
RUN sed -i "s/Basic/None/;s/Nagios Access/Public/;/AuthUserFile/d;s/valid-user/all granted/" /etc/apache2/conf-available/pnp4nagios.conf \
    && rm /usr/local/pnp4nagios/share/install.php

# Install https://github.com/Icinga/icingaweb2-module-pnp
#RUN mkdir -p /usr/share/icingaweb2/modules
#RUN cd /usr/share/icingaweb2/modules
#RUN git clone https://github.com/Icinga/icingaweb2-module-pnp pnp
COPY icingaweb2-module-pnp /usr/share/icingaweb2/modules/pnp
RUN icingacli module enable pnp
# Access Web UI and set the config directory
#    && sed -i "s:/etc/pnp4nagios:/usr/local/pnp4nagios/etc:"  /etc/icingaweb2/modules/pnp/config.ini
# Enable perfdata
#    && icinga2 feature enable perfdata \

RUN cp -p /usr/local/pnp4nagios/etc/npcd.cfg /usr/local/pnp4nagios/etc/npcd.cfg.save
RUN sed -i "/^perfdata_spool_dir/ cperfdata_spool_dir = /var/spool/icinga2/perfdata" /usr/local/pnp4nagios/etc/npcd.cfg
# Start NPCD daemon

EXPOSE 80 443 5665

# Initialize and run Supervisor
ENTRYPOINT ["/opt/run"]
