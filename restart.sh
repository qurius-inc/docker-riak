#! /bin/sh

chown riak:riak /var/lib/riak
chown riak:riak /var/log/riak

rm -rf /var/lib/riak/ring/*

credentialPath=/var/lib/riak/.credential
key=$(cat $credentialPath | grep -Po 'key: \K(.*?)')
secret=$(cat $credentialPath | grep -Po 'secret: \K(.*?)')

sed -i.bak "s/riak@[0-9]*.[0-9]*.[0-9]*.[0-9]*/riak@$(hostname -i)/" /etc/riak/riak.conf
sed -i.bak "s/riak-cs@[0-9]*.[0-9]*.[0-9]*.[0-9]*/riak-cs@$(hostname -i)/" /etc/riak-cs/riak-cs.conf
sed -i.bak "s/stanchion@[0-9]*.[0-9]*.[0-9]*.[0-9]*/stanchion@$(hostname -i)/" /etc/stanchion/stanchion.conf


sed -i.bak "s/admin.key = admin-key/admin.key = $key/" /etc/riak-cs/riak-cs.conf
sed -i.bak "s/admin.secret = admin-secret/admin.key = $secret/" /etc/riak-cs/riak-cs.conf


sed -i.bak "s/admin.key = admin-key/admin.key = $key/" /etc/stanchion/stanchion.conf
sed -i.bak "s/admin.secret = admin-secret/admin.key = $secret/" /etc/stanchion/stanchion.conf

sed -i.bak "s/access_key =/access_key = $key/" /root/.s3cfg
sed -i.bak "s/secret_key =/secret_key = $secret/" /root/.s3cfg

echo "starting riak"
riak start;
echo "starting stanchion"
stanchion start;
echo "starting riak-cs"
riak-cs start;

echo "wait 10 sec for service to start"
sleep 10

echo "done"

echo "default s3 bucket port: 8180"

/bin/bash
