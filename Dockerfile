#
# Copyright (c) 2018 Dell Inc., or its subsidiaries. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#

FROM logstash:5.6.4
MAINTAINER Lida He "https://github.com/hldnova"

# Pravega version
ENV PRAVEGA_VERSION=0.2.1

# Logstash Pravega output plugin version
ENV PLUGIN_VERSION=0.2.0

RUN apt update && \
    apt install -y --no-install-recommends \
        wget supervisor procps net-tools curl && \
    rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf ~/.cache && rm -rf /usr/share/doc

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

ADD access-sample.log /opt/data/access.log

ADD entrypoint.sh /opt/

EXPOSE 9090
EXPOSE 9091

ENV TERM linux

# default command
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
