#! /bin/sh

sed -i.bak "s/riak@[0-9]*.[0-9]*.[0-9]*.[0-9]*/riak@$(hostname -i)/" /etc/riak/riak.conf
sed -i.bak "s/riak-cs@[0-9]*.[0-9]*.[0-9]*.[0-9]*/riak-cs@$(hostname -i)/" /etc/riak-cs/riak-cs.conf
sed -i.bak "s/stanchion@[0-9]*.[0-9]*.[0-9]*.[0-9]*/stanchion@$(hostname -i)/" /etc/stanchion/stanchion.conf

sed -i.bak "s/proxy_host = [0-9]*.[0-9]*.[0-9]*.[0-9]*/proxy_host = $(hostname -i)/" ~/.s3cfg

/bin/bash
