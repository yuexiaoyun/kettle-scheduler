FROM tomcat:9-jre8-alpine

# Download PDI
ENV PDI_RELEASE=8.0 \
    PDI_VERSION=8.0.0.0-28\
    PDI_HOME=/data-integration
RUN apk add --update wget unzip && \
  mkdir /pentaho && \
  echo https://downloads.sourceforge.net/project/pentaho/Pentaho%20${PDI_RELEASE}/client-tools/pdi-ce-${PDI_VERSION}.zip | xargs wget --progress=dot:giga -qO- -O tmp.zip && \
  unzip -q tmp.zip -d /pentaho && \
  mv /pentaho/data-integration /data-integration && \
  mr -fr /pentaho && \
  rm -f tmp.zip && \
  apk del wget unzip 
RUN ln ${CATALINA_HOME}/plugins ${CATALINA_HOME}/plugins && \
  ln ${CATALINA_HOME}/system $CATALINA_HOME/system  && \
  ln ${CATALINA_HOME}/simple-jndi ${CATALINA_HOME}/simple-jndi

# Download JDBC
ENV MYSQL_JDBC_VERSION=8.0.16
# https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.16.tar.gz
RUN curl -L -o /tmp/mysql_connector.tar.gz "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_JDBC_VERSION}.tar.gz" \
       && tar -zxvf /tmp/mysql_connector.tar.gz -C ${CATALINA_HOME}/lib/ "mysql-connector-java-${MYSQL_JDBC_VERSION}/mysql-connector-java-${MYSQL_JDBC_VERSION}.jar" --strip-components 1 \
       && cp ${CATALINA_HOME}/lib/mysql-connector-java-${MYSQL_JDBC_VERSION}-bin.jar ${PDI_HOME}/lib/mssql-jdbc-${MYSQL_JDBC_VERSION}.jre8.jar \
       && rm /tmp/mysql_connector.tar.gz 
ENV MSSQL_JDBC_VERSION=7.2.2
# https://github.com/microsoft/mssql-jdbc/releases/download/v7.2.2/mssql-jdbc-7.2.2.jre8.jar
RUN   curl -L -o /tmp/mssql-jdbc.jre8.jar "https://github.com/Microsoft/mssql-jdbc/releases/download/v${MSSQL_JDBC_VERSION}/mssql-jdbc-${MSSQL_JDBC_VERSION}.jre8.jar" \
       && cp /tmp/mssql-jdbc.jre8.jar ${PDI_HOME}/lib/mssql-jdbc.jre8.jar \
       && cp /tmp/mssql-jdbc.jre8.jar ${CATALINA_HOME}/lib/mssql-jdbc.jre8.jar \
       && rm -f /tmp/mssql-jdbc.jre8.jar

# # ADD ./kettle-scheduler ./webapps/km
# https://nchc.dl.sourceforge.net/project/pentaho/Pentaho%208.0/client-tools/pdi-ce-8.0.0.0-28.zip

