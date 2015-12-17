Scaling xivo ctid with consul, consul-template, haproxy, docker and docker-compose

* consul: http://consul.io
* consul-template: https://github.com/hashicorp/consul-template
* haproxy: http://haproxy.org
* docker: http://docker.com
* docker-compose: https://docs.docker.com/compose/
* docker-machine: https://docs.docker.com/machine/
* xivo: http://xivo.io

Please note, it's possible to do the same thing with many other services on xivo, it's only a guide to scale services.

prerequisite
------------

Docker, docker-compose and optionnaly docker-machine need to be installed. You also need a xivo 15.19 installed. To get xivo, go the xivo.io, it's a free software ;)

Please note consul is already installed on xivo.

XiVO configuration
------------------

Add a user to rabbitmq

    rabbitmqctl add_user xivo xivo
    rabbitmqctl set_user_tags xivo administrator
    rabbitmqctl set_permissions -p / xivo ".*" ".*" ".*" 

Configure postgresql, change the listen addresses in /etc/postgresql/9.1/main/postgresql.conf to

    listen_addresses = '*'

Add in /etc/postgresql/9.1/main/pg_hba.conf

    host    all             all             your_subnet/24          md5

Restart Postgresql

    service postgresql restart

Configure manager user and add a config file in /etc/asterisk/manager.d/myconfig.conf 

    [xivo_cti_user]
    permit=your_subnet/255.255.255.0

And reload the asterisk configuration:

    asterisk -rx "manager reload"

Update your cti config, add config file in /etc/xivo-ctid/conf.d/myconfig.yml

    rest_api:
      http:
        listen: 0.0.0.0
    service_discovery:
      advertise_address: 192.168.1.124  # IP address of this XiVO, reachable from outside
      check_url: http://192.168.1.124:9495/0.1/infos

Restart your CTI.

    service xivo-ctid restart

Installation
------------

Set the address IP of XiVO on docker-compose.yml on section extra_hosts.

To build ctid on docker:

    docker build -t xivo/ctid https://github.com/xivo-pbx/xivo-ctid.git

To build lb:

    docker build -t xivo/lb-consul-template -f dockerfile/consul-template/Dockerfile .

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

To get stats from docker

    docker stats $(docker ps -q)

Warning, please be sure the loadblancer timeout and the connection time on xivo client is configured correctly. By default on xivo client, it's 120s and on my default lb config it's 125s, be sure if you are changing on xivo client this timeout, the timeout on LB need to be greater than the client.

XiVO client
-----------

Use the ip address of the loadbalancer on your xivo client.
