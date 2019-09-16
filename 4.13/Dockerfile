FROM openjdk:8-jre-alpine
MAINTAINER Francis Chuang <francis.chuang@boostport.com>

ARG HBASE_VERSION
ARG PHOENIX_VERSION

# The busybox wget is broken, so we install a vanilla wget. Remove when resolved.
# See https://github.com/gliderlabs/docker-alpine/issues/292
RUN apk --no-cache --update add bash ca-certificates gnupg openssl python tar wget \
 && apk --no-cache --update --repository https://dl-3.alpinelinux.org/alpine/edge/community/ add xmlstarlet \
 && update-ca-certificates \
\
# Set up directories
 && mkdir -p /opt/hbase \
 && mkdir -p /opt/phoenix \
 && mkdir -p /opt/phoenix-server \
\
# Download HBase
 && wget -O /tmp/KEYS https://archive.apache.org/dist/hbase/KEYS \
 && gpg --import /tmp/KEYS \
 && wget -q -O /tmp/hbase.tar.gz http://archive.apache.org/dist/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz \
 && wget -O /tmp/hbase.asc https://archive.apache.org/dist/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz.asc \
 && gpg --verify /tmp/hbase.asc /tmp/hbase.tar.gz \
 && tar -xzf /tmp/hbase.tar.gz -C /opt/hbase  --strip-components 1 \
\
# Download Phoenix
 && wget -O /tmp/KEYS https://archive.apache.org/dist/phoenix/KEYS \
 && gpg --import /tmp/KEYS \
 && HBASE_MINOR_VERSION=$(echo $HBASE_VERSION | grep -o '[[:digit:]]\+\.[[:digit:]]\+') \
 && wget -q -O /tmp/phoenix.tar.gz http://archive.apache.org/dist/phoenix/apache-phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION/bin/apache-phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-bin.tar.gz \
 && wget -O /tmp/phoenix.asc https://archive.apache.org/dist/phoenix/apache-phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION/bin/apache-phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-bin.tar.gz.asc \
 && gpg --verify /tmp/phoenix.asc /tmp/phoenix.tar.gz \
 && tar -xzf /tmp/phoenix.tar.gz -C /opt/phoenix --strip-components 1 \
\
# Set up HBase and Phoenix
 && mv /opt/phoenix/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-server.jar /opt/hbase/lib/ \
 && cp /opt/phoenix/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-client.jar /opt/hbase/lib/ \
 && mv /opt/phoenix/bin/tephra /opt/hbase/bin/tephra \
 && mv /opt/phoenix/bin/tephra-env.sh /opt/hbase/bin/tephra-env.sh \
 && mv /opt/phoenix/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-queryserver.jar /opt/phoenix-server/ \
 && mv /opt/phoenix/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MINOR_VERSION-client.jar /opt/phoenix-server/ \
 && mv /opt/phoenix/bin /opt/phoenix-server/bin \
\
# Replace hbase's guava 12 jar with the guava 13 jar. Remove when TEPHRA-181 is resolved.
 && rm /opt/hbase/lib/guava-12.0.1.jar \
 && wget -P /opt/hbase/lib https://search.maven.org/remotecontent?filepath=com/google/guava/guava/13.0.1/guava-13.0.1.jar \
\
# Clean up
 && apk del gnupg openssl tar \
 && rm -rf /opt/phoenix /tmp/* /var/tmp/* /var/cache/apk/*

EXPOSE 8765

ADD start-hbase-phoenix.sh /start-hbase-phoenix.sh

CMD ["/start-hbase-phoenix.sh"]