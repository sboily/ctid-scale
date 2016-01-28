

build:
	docker build -t xivo/ctid https://github.com/xivo-pbx/xivo-ctid.git
	docker build -t xivo/lb-consul-template -f dockerfile/consul-template/Dockerfile dockerfile/consul-template/
