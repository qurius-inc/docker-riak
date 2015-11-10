#! /bin/sh

chown riak:riak /var/lib/riak
chown riak:riak /var/log/riak

rm -rf /var/lib/riak/*
rm -rf /var/log/riak/*

sed -i.bak "s/riak@[0-9]*.[0-9]*.[0-9]*.[0-9]*/riak@$(hostname -i)/" /etc/riak/riak.conf
sed -i.bak "s/riak-cs@[0-9]*.[0-9]*.[0-9]*.[0-9]*/riak-cs@$(hostname -i)/" /etc/riak-cs/riak-cs.conf
sed -i.bak "s/stanchion@[0-9]*.[0-9]*.[0-9]*.[0-9]*/stanchion@$(hostname -i)/" /etc/stanchion/stanchion.conf

echo "starting riak"
riak start;
echo "starting stanchion"
stanchion start;
echo "starting riak-cs"
riak-cs start;

echo "wait 10 sec for service to start"
sleep 10

echo "generate key and secret"
R=$(curl -XPOST http://localhost:8080/riak-cs/user  -H 'Content-Type: application/json' -d '{"email":"admin@admin.com", "name":"admin"}')

key=$(echo $R | grep -Po '"key_id":"\K(.*?)(?=")')
secret=$(echo $R | grep -Po '"key_secret":"\K(.*?)(?=")')

credentialPath=/var/lib/riak/.credential
rm $credentialPath
touch $credentialPath
echo key: $key >> $credentialPath
echo secret: $secret >> $credentialPath 

echo "*** ***"
echo "key: $key"
echo "secret: $secret"
echo "*** ***"
echo "Saved in " $credentialPath

sed -i.bak "s/admin.key = admin-key/admin.key = $key/" /etc/riak-cs/riak-cs.conf
sed -i.bak "s/admin.secret = admin-secret/admin.key = $secret/" /etc/riak-cs/riak-cs.conf


sed -i.bak "s/admin.key = admin-key/admin.key = $key/" /etc/stanchion/stanchion.conf
sed -i.bak "s/admin.secret = admin-secret/admin.key = $secret/" /etc/stanchion/stanchion.conf

sed -i.bak "s/access_key =/access_key = $key/" /root/.s3cfg
sed -i.bak "s/secret_key =/secret_key = $secret/" /root/.s3cfg

echo "restart stanchion"
stanchion restart;
echo "restart riak-cs"
riak-cs restart;

echo "create s3 bucket s3://test-bucket"
s3cmd mb s3://test-bucket

echo "done"

echo "default s3 bucket port: 8180"

/bin/bash
