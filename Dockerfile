# Riak
#
# VERSION       1.0.5
#
# credit Hector Castro for base
FROM phusion/baseimage:0.9.14
MAINTAINER Newton Truong

# Environmental variables
ENV DEBIAN_FRONTEND noninteractive
ENV RIAK_VERSION 2.0.2-1

RUN \

    # Install Java 7
    sed -i.bak 's/main$/main universe/' /etc/apt/sources.list && \
    apt-get update -qq && apt-get install -y software-properties-common && \
    apt-add-repository ppa:webupd8team/java -y && apt-get update -qq && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java7-installer && \

    # Install Riak
    curl https://packagecloud.io/install/repositories/basho/riak/script.deb.sh | bash && \
    apt-get install -y riak=${RIAK_VERSION} && \

    curl -O http://s3.amazonaws.com/downloads.basho.com/riak-cs/2.1/2.1.0/ubuntu/trusty/riak-cs_2.1.0-1_amd64.deb && \
    dpkg -i riak-cs_2.1.0-1_amd64.deb && \

    curl -O http://s3.amazonaws.com/downloads.basho.com/stanchion/2.1/2.1.0/ubuntu/trusty/stanchion_2.1.0-1_amd64.deb && \
    dpkg -i stanchion_2.1.0-1_amd64.deb && \

    apt-get -y install s3cmd  && \

    # Cleanup
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup the Riak service
RUN mkdir -p /etc/service/riak
ADD bin/riak.sh /etc/service/riak/run

RUN mkdir -p /var/lib/riak; chown -R riak:riak /var/lib/riak;
Run mkdir -p /var/log/riak; chown -R riak:riak /var/log/riak;

# Setup automatic clustering
ADD bin/automatic_clustering.sh /etc/my_init.d/99_automatic_clustering.sh

# Tune Riak configuration settings for the container
RUN sed -i.bak 's/listener.http.internal = 127.0.0.1/listener.http.internal = 0.0.0.0/' /etc/riak/riak.conf && \
    sed -i.bak 's/listener.protobuf.internal = 127.0.0.1/listener.protobuf.internal = 0.0.0.0/' /etc/riak/riak.conf && \
    sed -i.bak 's/storage_backend = bitcask/buckets.default.allow_mult = true/' /etc/riak/riak.conf && \
    echo "anti_entropy.concurrency_limit = 1" >> /etc/riak/riak.conf && \
    echo "javascript.map_pool_size = 0" >> /etc/riak/riak.conf && \
    echo "javascript.reduce_pool_size = 0" >> /etc/riak/riak.conf && \
    echo "javascript.hook_pool_size = 0" >> /etc/riak/riak.conf && \
    sed -i.bak 's/listener = 127.0.0.1:8080/listener = 0.0.0.0:8080/' /etc/riak-cs/riak-cs.conf && \
    sed -i.bak 's/riak_host = 127.0.0.1:8087/riak_host = 0.0.0.0:8087/' /etc/riak-cs/riak-cs.conf && \
    sed -i.bak 's/anonymous_user_creation = off/anonymous_user_creation = on/' /etc/riak-cs/riak-cs.conf && \
    sed -i.bak 's/stanchion_host = 127.0.0.1:8085/stanchion_host = 0.0.0.0:8085/' /etc/riak-cs/riak-cs.conf && \
    sed -i.bak 's/stanchion_host = 127.0.0.1:8085/stanchion_host = 0.0.0.0:8085/' /etc/stanchion/stanchion.conf && \
    sed -i.bak 's/riak_host = 127.0.0.1:8087/riak_host = 0.0.0.0:8087/' /etc/stanchion/stanchion.conf

# Make Riak's data and log directories volumes
#VOLUME /var/lib/riak
#VOLUME /var/log/riak

# Open ports for HTTP and Protocol Buffers
EXPOSE 8098 8087 8080

# Enable insecure SSH key
# See: https://github.com/phusion/baseimage-docker#using_the_insecure_key_for_one_container_only
RUN /usr/sbin/enable_insecure_key

# Config files
COPY advanced.config /etc/riak/
COPY s3cfg /root/.s3cfg

# Helper files
COPY setup.sh /bin/
RUN chmod +x /bin/setup.sh
COPY restart.sh /bin/
RUN chmod +x /bin/restart.sh

# Leverage the baseimage-docker init system
# CMD ["/sbin/my_init", "--quiet"]
CMD /bin/restart.sh;
