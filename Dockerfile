FROM tomcat:9-jre8-alpine

ENV MINOR_VERSION 8.0.0.0-28
ENV PENTAHO_HOME /pentaho

RUN apk add --update wget unzip && \
  mkdir ${PENTAHO_HOME} && \
  echo http://downloads.sourceforge.net/project/pentaho/Data%20Integration/${MAJOR_VERSION}/pdi-ce-${MINOR_VERSION}.zip | xargs wget -qO- -O tmp.zip && \
  unzip -q tmp.zip -d ${PENTAHO_HOME} && \
  rm -f tmp.zip && \
  apk del wget unzip

# ADD ./pdi/data-integration /data-integration

RUN ln /data-integration/plugins ${CATALINA_HOME}/plugins \
    && ln /data-integration/system $CATALINA_HOME/system \
    && ln /data-integration/simple-jndi ${CATALINA_HOME}/simple-jndi

RUN curl -L -o /tmp/mysql_connector.tar.gz "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.45.tar.gz" \
       && mkdir /opt/solr/contrib/dataimporthandler/lib \
       && tar -zxvf /tmp/mysql_connector.tar.gz -C $CATALINA_HOME/lib/ "mysql-connector-java-5.1.45/mysql-connector-java-5.1.45-bin.jar" --strip-components 1 \
       && cp ${CATALINA_HOME}/lib/mysql-connector-java-5.1.45-bin.jar ${PENTAHO_HOME}/data-integration/lib/mssql-jdbc-7.2.1.jre8.jar \
       && rm /tmp/mysql_connector.tar.gz 

RUN curl -L -o /tmp/mssql-jdbc-7.2.1.jre8.jar "https://github.com/Microsoft/mssql-jdbc/releases/download/v7.2.1/mssql-jdbc-7.2.1.jre8.jar" \
       && cp /tmp/mssql-jdbc-7.2.1.jre8.jar ${PENTAHO_HOME}/data-integration/lib/mssql-jdbc-7.2.1.jre8.jar \
       && cp /tmp/mssql-jdbc-7.2.1.jre8.jar ${CATALINA_HOME}/lib/mssql-jdbc-7.2.1.jre8.jar \
       && rm -f /tmp/mssql-jdbc-7.2.1.jre8.jar

# ADD ./kettle-scheduler ./webapps/km


