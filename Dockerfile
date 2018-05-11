# Docker container for Pravega
FROM ubuntu:xenial
MAINTAINER Lida He "https://github.com/hldnova"


RUN apt update && \
    apt install -y --no-install-recommends \
        wget supervisor curl net-tools  \
        apt-transport-https \
        software-properties-common && \
    rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf ~/.cache && rm -rf /usr/share/doc

# Install Java.
RUN \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt update && \
    apt install -y --no-install-recommends oracle-java8-installer && \
    rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf ~/.cache && rm -rf /usr/share/doc && \
    rm -rf /var/cache/oracle-jdk8-installer

# Install logstash
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list && \
    apt update && apt install -y --no-install-recommends logstash && \
    rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf ~/.cache && rm -rf /usr/share/doc

# Pravega version
ENV PRAVEGA_VERSION=0.2.1

# Logstash Pravega output plugin version
ENV PLUGIN_VERSION=0.2.0

# Install Pravega
RUN cd /opt && \
    wget --no-check-certificate https://github.com/pravega/pravega/releases/download/v${PRAVEGA_VERSION}/pravega-${PRAVEGA_VERSION}.tgz && \
    tar xfvz pravega-${PRAVEGA_VERSION}.tgz && \
    ln -s /opt/pravega-${PRAVEGA_VERSION} /opt/pravega && \
    rm -rf /opt/pravega-${PRAVEGA_VERSION}.tgz

# Install logstash Pravega output plugin
RUN cd /opt && \
    wget --no-check-certificate https://github.com/pravega/logstash-output-pravega/releases/download/v${PLUGIN_VERSION}/logstash-output-pravega-${PLUGIN_VERSION}.gem && \
    /usr/share/logstash/bin/logstash-plugin install logstash-output-pravega-${PLUGIN_VERSION}.gem && \
    rm -rf logstash-output-pravega-${PLUGIN_VERSION}.gem

ADD supervisord.conf /etc/supervisord.conf

ADD supervisord_pravega.conf /etc/supervisor/conf.d/pravega-standalone.conf

RUN mkdir -p /var/log/pravega
RUN mkdir -p /opt/data

ADD filters/* /etc/logstash/conf.d/

ADD entrypoint.sh /opt/

EXPOSE 9090
EXPOSE 9091

ENV TERM linux

# default command
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
