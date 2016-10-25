# JRE should suffice, but if building phoenix from source we need to use JDK
FROM openjdk:8-jdk-alpine
MAINTAINER Francis Chuang <francis.chuang@boostport.com>

ENV HBASE_VERSION=1.2.3 HBASE_MINOR_VERSION=1.2 PHOENIX_VERSION=4.9.0

 # git and maven are only used for building snapshots
RUN apk --no-cache --update add bash ca-certificates gnupg openssl python tar git \
 && apk --no-cache --update --repository https://dl-3.alpinelinux.org/alpine/edge/community/ add xmlstarlet maven \
 && update-ca-certificates \
\
# Set up directories
 && mkdir -p /opt/hbase \
 && mkdir -p /opt/phoenix \
 && mkdir -p /opt/phoenix-server \
\
# Download HBase
 && wget -O /tmp/KEYS https://www-us.apache.org/dist/hbase/KEYS \
 && gpg --import /tmp/KEYS \
 && wget -q -O /tmp/hbase.tar.gz http://apache.mirror.digitalpacific.com.au/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz \
 && wget -O /tmp/hbase.asc https://www-us.apache.org/dist/hbase/stable/hbase-$HBASE_VERSION-bin.tar.gz.asc \
 && gpg --verify /tmp/hbase.asc /tmp/hbase.tar.gz \
 && tar -xzf /tmp/hbase.tar.gz -C /opt/hbase  --strip-components 1 \
\
# Download Phoenix
# && wget -O /tmp/KEYS https://www-us.apache.org/dist/phoenix/KEYS \
# && gpg --import /tmp/KEYS \
# && wget -q -O /tmp/phoenix.tar.gz http://apache.uberglobalmirror.com/phoenix/apache-phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION/bin/apache-phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-bin.tar.gz \
# && wget -O /tmp/phoenix.asc https://www-eu.apache.org/dist/phoenix/apache-phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION/bin/apache-phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-bin.tar.gz.asc \
# && gpg --verify /tmp/phoenix.asc /tmp/phoenix.tar.gz \
# && tar -xzf /tmp/phoenix.tar.gz -C /opt/phoenix --strip-components 1 \
# Build Phoenix
 && cd /tmp \
 && git clone https://github.com/apache/phoenix.git \
 && cd phoenix \
 && git checkout a5bcb3ea9a86b800b44b1d7815b094d7a952a11b \
 && mvn package \
\
# Set up HBase and Phoenix
 && mv /tmp/phoenix/phoenix-server/target/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-SNAPSHOT-server.jar /opt/hbase/lib/ \
 && cp /tmp/phoenix/phoenix-client/target/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-SNAPSHOT-client.jar /opt/hbase/lib/ \
 && mv /tmp/phoenix/bin/tephra /opt/hbase/bin/tephra \
 && mv /tmp/phoenix/bin/tephra-env.sh /opt/hbase/bin/tephra-env.sh \
 && mv /tmp/phoenix/phoenix-queryserver/target/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-SNAPSHOT-queryserver.jar /opt/phoenix-server/ \
 && mv /tmp/phoenix/phoenix-client/target/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-SNAPSHOT-client.jar /opt/phoenix-server/ \
 && mv /tmp/phoenix/bin /opt/phoenix-server/bin \
# && mv /opt/phoenix/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-server.jar /opt/hbase/lib/ \
# && cp /opt/phoenix/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-client.jar /opt/hbase/lib/ \
# && mv /opt/phoenix/bin/tephra /opt/hbase/bin/tephra \
# && mv /opt/phoenix/bin/tephra-env.sh /opt/hbase/bin/tephra-env.sh \
# && mv /opt/phoenix/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-queryserver.jar /opt/phoenix-server/ \
# && mv /opt/phoenix/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-client.jar /opt/phoenix-server/ \
# && mv /opt/phoenix/bin /opt/phoenix-server/bin \
\
# Replace hbase's guava 12 jar with the guava 13 jar. Remove when TEPHRA-181 is resolved.
 && rm /opt/hbase/lib/guava-12.0.1.jar \
 && wget -P /opt/hbase/lib https://search.maven.org/remotecontent?filepath=com/google/guava/guava/13.0.1/guava-13.0.1.jar \
\
# Clean up
# remove git and maven, which are used for building snapshots
 && apk del gnupg openssl tar git maven \
 && rm -rf /opt/phoenix /tmp/* /var/tmp/* /var/cache/apk/*

EXPOSE 8765

ADD start-hbase-phoenix.sh /start-hbase-phoenix.sh

CMD ["./start-hbase-phoenix.sh"]