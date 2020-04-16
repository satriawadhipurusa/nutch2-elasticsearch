FROM ubuntu:18.04

LABEL maintainer="satriawicaksanaadhipurusa@gmail.com"

ENV JAVA_HOME "/usr/lib/jvm/java-8-openjdk-amd64"
ENV NUTCH_HOME "/root/nutch_service/apache-nutch/runtime/local"

RUN apt-get update && apt-get install -y ant git wget openjdk-8-jdk \
    && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --set java $JAVA_HOME/jre/bin/java \
    && echo "export JAVA_HOME=${JAVA_HOME}" >> $HOME/.bashrc

WORKDIR /root/nutch_service

RUN wget https://archive.apache.org/dist/hbase/hbase-0.94.14/hbase-0.94.14.tar.gz \
    && tar -xzf hbase-0.94.14.tar.gz \
    && rm hbase-0.94.14.tar.gz \
    && mv hbase-0.94.14 hbase

RUN wget https://archive.apache.org/dist/nutch/2.3/apache-nutch-2.3-src.tar.gz \
    && tar -xzf apache-nutch-2.3-src.tar.gz \
    && rm apache-nutch-2.3-src.tar.gz \
    && mv apache-nutch-2.3 apache-nutch

RUN git clone --single-branch --depth 1 https://github.com/satriawadhipurusa/nutch2-elasticsearch.git \
    && cp nutch2-elasticsearch/configs/hbase-site.xml hbase/conf/hbase-site.xml \
    && echo "gora.datastore.default=org.apache.gora.hbase.store.HBaseStore" >> apache-nutch/conf/gora.properties \
    && cp nutch2-elasticsearch/configs/ivy* apache-nutch/ivy \
    && cd apache-nutch && ant runtime

WORKDIR /root/nutch_service

RUN mkdir urls \ 
    && touch urls/seed.txt \
    && cp nutch2-elasticsearch/configs/nutch-site.xml $NUTCH_HOME/conf/ \
    && { \
        echo "export NUTCH_HOME=${NUTCH_HOME}"; \
        echo "export PATH=$PATH:$NUTCH_HOME/bin:$JAVA_HOME/bin"; \
        } >> $HOME/.bashrc \
    && cp nutch2-elasticsearch/startup.sh nutch2-elasticsearch/crawl . \
    && cp nutch2-elasticsearch/crawl $NUTCH_HOME/bin/ \
    && chmod +x startup.sh

EXPOSE 8080
EXPOSE 8081

ENTRYPOINT [ "./startup.sh" ]