from haproxy
MAINTAINER Sylvain Boily "sboily@avencall.com"

ENV VERSION 0.12.1

RUN apt-get -yqq update \
    && apt-get -yqq install \
                    procps \
                    unzip \
                    sysvinit-utils

WORKDIR /usr/src
ADD https://releases.hashicorp.com/consul-template/${VERSION}/consul-template_${VERSION}_linux_amd64.zip /usr/src/
RUN unzip consul-template_${VERSION}_linux_amd64.zip
RUN mv consul-template /usr/bin

RUN rm -rf consul-template*

RUN mkdir /var/run/haproxy/
RUN touch /var/run/haproxy/haproxy.pid

ADD ./config /config
ONBUILD ADD ./config /config

CMD consul-template -log-level debug -config /config/template.hcl
