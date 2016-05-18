Scaling xivo ctid with consul, consul-template, haproxy, docker and docker-compose

* consul: http://consul.io >= 0.6.4
* consul-template: https://github.com/hashicorp/consul-template >= 0.14.0
* haproxy: http://haproxy.org
* docker: http://docker.com >= 1.11.1
* docker-compose: https://docs.docker.com/compose/ >= 1.7.0
* xivo: http://xivo.io >= 16.06

prerequisite
------------

Docker and docker-compose need to be installed. You also need a xivo 16.06 installed. To get xivo, go to xivo.io, it's a free software ;)

Please note consul is already installed on xivo by default.

XiVO configuration
------------------

Add a user to rabbitmq

    rabbitmqctl add_user xivo xivo
    rabbitmqctl set_user_tags xivo administrator
    rabbitmqctl set_permissions -p / xivo ".*" ".*" ".*" 

Configure postgresql, change the listen addresses in /etc/postgresql/9.1/main/postgresql.conf to

    listen_addresses = '*'

Add in /etc/postgresql/9.4/main/pg_hba.conf

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
      advertise_address: auto
      advertise_address_interface: eth0

Restart your CTI.

    service xivo-ctid restart

Installation
------------

Export variables:

- XIVO_HOST
- XIVO_UUID
- CONSUL_HOST
- CONSUL_PORT
- CONSUL_TOKEN

To build it:

    make build

Update key.yml to have the good credentials for the CTID. You can get it on your xivo on /var/lib/xivo-auth-keys/xivo-ctid-key.yml.
Update ctid.yml to have the good token to connect on consul.

To get your XIVO_UUID:

    su - postgres
    psql asterisk
    select * from infos;

- config/ctid/conf.d/cti.yml
- config/ctid/key.yml

On docker-compose.yml:

- Set ip address of your xivo on extra_host
- Update the consul ip and token on section lb

To start :

    docker-compose up -d

To scale up ctid service :

    docker-compose scale ctid=10

to scale down :

    docker-compose scale ctid=1

To clean docker-compose

    docker-compose kill
    docker-compose rm -f

To get stats from docker

    docker stats $(docker ps -q)

Consul
------

To clean consul services:

The consul-cli tools is available on xivo, you need to install with

    apt-get install consul-cli
    consul-cli service-deregister serviceID

or magical command:

    consul-cli agent services --ssl --ssl-verify=0 | jq '.[] | {"ID": .ID, "Service": .Service} | select(.Service == "xivo-ctid") | .ID' | xargs -p -L1 consul-cli service deregister --ssl --ssl-verify=0 

To get service ID, you can list all services with this url

    https://ip_consul:8500/v1/catalog/services?token=one_ring

To get every serviceID from a service.

    https://ip_consul:8500/v1/catalog/service/xivo-ctid?token=on_ring

Haproxy
-------

To use the haproxy web interface, please connect to (login/pass: xivo/xivo)

    http://your_ip_expose:1936/

Warning, please be sure the loadblancer timeout and the connection time on xivo client is configured correctly. By default on xivo client, it's 120s and on my default lb config it's 125s, be sure if you are changing on xivo client this timeout, the timeout on LB need to be greater than the client.

XiVO client
-----------

Use the ip address of the loadbalancer on your xivo client.
