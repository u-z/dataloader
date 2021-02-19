FROM centos:7
MAINTAINER okazakiyuji <zaki@mbf.nifty.com>
RUN yum -y update && \
    yum -y install git svn java-1.8.0-openjdk maven unzip mysql && \
    rm -rf /var/cache/yum/* && \
    yum clean all
# make directory
ENV DL_ROOT /opt/dataloader
RUN mkdir -p $DL_ROOT && cd $DL_ROOT && mkdir bin conf data status log
# Build Dataloader 
WORKDIR /tmp
ENV DL_VER 51.0.1
ENV DL_FILE v51.0.1
ENV DL_FOLDER dataloader-51.0.1
ADD https://github.com/forcedotcom/dataloader/archive/$DL_FILE.zip ./
RUN unzip $DL_FILE.zip && \
    cd ./$DL_FOLDER && \
    mvn clean package -DskipTests && \
    mv target/dataloader-$DL_VER-uber.jar $DL_ROOT/bin/ && \
    cp license.txt $DL_ROOT/bin/ && \
    cd .. && rm -r ./$DL_FOLDER ./$DL_FILE.zip 
# Install mysql connector
ENV MYSQL_CON_VER 2.7.2
ADD https://downloads.mariadb.com/Connectors/java/connector-java-$MYSQL_CON_VER/mariadb-java-client-$MYSQL_CON_VER.jar $DL_BIN_DIR/
#
ENV DATALOADER_CLASSPATH $DL_ROOT/bin/mariadb-java-client-$MYSQL_CON_VER.jar:$DL_ROOT/bin/dataloader-$DL_VER-uber.jar
ENV PATH $PATH:$DL_ROOT/bin
ENV DL_BIN_DIR $DL_ROOT/bin

