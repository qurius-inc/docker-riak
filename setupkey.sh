#! /bin/sh

riak start;
stanchion start;
riak-cs start;

R=$(curl -XPOST http://localhost:8080/riak-cs/user  -H 'Content-Type: application/json' -d '{"email":"admin@admin.com", "name":"admin"}')

key=$(echo $R | grep -Po '"key_id":"\K(.*?)(?=")')
secret=$(echo $R | grep -Po '"key_secret":"\K(.*?)(?=")')

echo "key: $key"
echo "secret: $secret"

sed -i.bak "s/admin.key = admin-key/admin.key = $key/" /etc/riak-cs/riak-cs.conf
sed -i.bak "s/admin.secret = admin-secret/admin.key = $secret/" /etc/riak-cs/riak-cs.conf


sed -i.bak "s/admin.key = admin-key/admin.key = $key/" /etc/riak/riak.conf
sed -i.bak "s/admin.secret = admin-secret/admin.key = $secret/" /etc/riak/riak.conf

sed -i.bak "s/access_key =/access_key = $key/" /root/.s3cfg
sed -i.bak "s/secret_key =/secret_key = $secret/" /root/.s3cfg
