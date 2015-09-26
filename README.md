Scaling xivo ctid with consul, consul-template, haproxy, docker, docker-compose and registrator

* consul: http://consul.io
* consul-template: https://github.com/hashicorp/consul-template
* haproxy: http://haproxy.org
* docker: http://docker.com
* docker-compose: https://docs.docker.com/compose/
* docker-machine: https://docs.docker.com/machine/
* registrator: http://gliderlabs.com/registrator/latest/
* xivo: http://xivo.io

Please note, it's possible to do the same thing with many other services on xivo, it's only a guide to scale services.

prerequisite
------------

Docker, docker-compose and optionnaly docker-machine need to be installed. You also need a xivo 15.15 installed. To get xivo, go the xivo.io, it's a free software ;)

Please note consul is already installed on xivo.

XiVO configuration
------------------

Add a user to rabbitmq

    rabbitmqctl add_user xivo xivo
    rabbitmqctl set_user_tags xivo administrator
    rabbitmqctl set_permissions -p / xivo ".*" ".*" ".*" 

Configure agentd, add a config file /etc/xivo-agentd/conf.d/my-config.yml 

    rest_api:
      listen: 0.0.0.0

Configure postgresql, change the listen addresses in /etc/postgresql/9.1/main/postgresql.conf to

    listen_addresses = '*'

Add in /etc/postgresql/9.1/main/pg_hba.conf

    host    all             all             your_subnet/24          md5

Restart Postgresql

    service postgresql restart

Configure asterisk manager, /etc/asterisk/manager.conf on xivo_cti_user section

    permit=your_subnet/255.255.0.0

And reload the asterisk configuration:

    asterisk -rx "manager reload"

Installation
------------

To configure ctid, please edit config/ctid/cti.yml and adapt the config and edited docker-compose.yml.

To build ctid on docker:

    mkdir $HOME/tmp
    cd $HOME/tmp
    git clone https://github.com/xivo-pbx/xivo-ctid.git
    cd xivo-ctid
    docker build -t xivo/ctid .

To build lb:

    cd dockerfile/consul-template
    docker build -t xivo/lb-consul-template .

To start :

    docker-compose up -d

To scale up ctid service :

    docker-compose scale ctid=10

to scale down :

    docker-compose scale ctid=1

To clean docker-compose

    docker-compose kill
    docker-compose rm -f

To clean consul services

    consul-cli service-deregister serviceID

The consul-cli tools is available on xivo, you need to install with

    apt-get install consul-cli

To get service ID, you can list all services with this url

    http://ip_consul:8500/v1/catalog/services

To get every serviceID from a service.

    http://ip_consul:8500/v1/catalog/service/cti-5003

To get LB infos, by default xivo/xivo

    http://ip_docker_lb:1936/

Warning, please be sure the loadblancer timeout and the connection time on xivo client is configured correctly. By default on xivo client, it's 120s and on my default lb config it's 125s, be sure if you are changing on xivo client this timeout, the timeout on LB need to be greater than the client.

XiVO client
-----------

Use the ip address of the loadbalancer on your xivo client.
