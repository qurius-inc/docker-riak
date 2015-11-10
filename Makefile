.PHONY: all build riak-container start-cluster test-cluster stop-cluster

all: stop-cluster riak-container start-cluster

build riak-container:
	docker build -t "qurius/riak" .

start-cluster:
	./bin/start-cluster.sh

test-cluster:
	./bin/test-cluster.sh

stop-cluster:
	./bin/stop-cluster.sh
