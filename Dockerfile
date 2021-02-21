FROM centos:8
MAINTAINER okazakiyuji <zaki@mbf.nifty.com>
# DataloaderはビルドするのにJava11が必要
RUN dnf -y update && \
    dnf -y install git svn which java-11-openjdk java-11-openjdk-devel unzip mysql && \
    rm -rf /var/cache/yum/* && yum clean all
# make directory
ENV DL_ROOT /opt/dataloader
RUN mkdir -p $DL_ROOT && cd $DL_ROOT && mkdir bin conf data status log
# Build Maven
# Mavenをdnfでインストールするとjava8がインストールされるのでバイナリを使用する
WORKDIR /opt
RUN curl -L -O https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.zip && \
    unzip apache-maven-3.6.3-bin.zip && \
    mv apache-maven-3.6.3 apache-maven && \
    rm apache-maven-3.6.3-bin.zip
ENV PATH $PATH:/opt/apache-maven/bin
# Build Dataloader
WORKDIR /tmp
# 51.0.1 はビルドできない
ENV DL_VER 50.0.0
ENV DL_FILE v50.0.0
ENV DL_FOLDER dataloader-50.0.0
RUN curl -L -O https://github.com/forcedotcom/dataloader/archive/$DL_FILE.zip && \
    unzip $DL_FILE.zip && cd $DL_FOLDER && \
    mvn clean package -DskipTests && \
    mv target/dataloader-$DL_VER-uber.jar $DL_ROOT/bin/ && \
    cp license.txt $DL_ROOT/bin/ && \
    rm -r /tmp/$DL_FOLDER /tmp/$DL_FILE.zip
ENV PATH $PATH:$DL_ROOT/bin
# Install mysql connector
WORKDIR $DL_ROOT/bin/
ENV MYSQL_CON_VER 2.7.2
RUN curl -L -O https://downloads.mariadb.com/Connectors/java/connector-java-$MYSQL_CON_VER/mariadb-java-client-$MYSQL_CON_VER.jar
ENV DATALOADER_CLASSPATH $DL_ROOT/bin/mariadb-java-client-$MYSQL_CON_VER.jar:$DL_ROOT/bin/dataloader-$DL_VER-uber.jar
#
WORKDIR /tmp
