FROM tomcat:9-jre8-alpine

# Download PDI
ENV PDI_VERSION 8.0.0.0-28
ENV PDI_HOME /data-integration
RUN apk add --update wget unzip && \
  mkdir /pentaho && \
  echo https://downloads.sourceforge.net/project/pentaho/Pentaho%208.0/server/pdi-ce-${PDI_VERSION}.zip | xargs wget -qO- -O tmp.zip && \
  unzip -q tmp.zip -d /pentaho && \
  mv /pentaho/data-integration /data-integration && \
  mr -fr /pentaho && \
  rm -f tmp.zip && \
  apk del wget unzip && \
  ln ${CATALINA_HOME}/plugins ${CATALINA_HOME}/plugins && \
  ln ${CATALINA_HOME}/system $CATALINA_HOME/system  && \
  ln ${CATALINA_HOME}/simple-jndi ${CATALINA_HOME}/simple-jndi

# Download JDBC
RUN curl -L -o /tmp/mysql_connector.tar.gz "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_JDBC_VERSION}.tar.gz" \
       && tar -zxvf /tmp/mysql_connector.tar.gz -C ${CATALINA_HOME}/lib/ "mysql-connector-java-${MYSQL_JDBC_VERSION}/mysql-connector-java-${MYSQL_JDBC_VERSION}.jar" --strip-components 1 \
       && cp ${CATALINA_HOME}/lib/mysql-connector-java-${MYSQL_JDBC_VERSION}-bin.jar ${PDI_HOME}/lib/mssql-jdbc-${MYSQL_JDBC_VERSION}.jre8.jar \
       && rm /tmp/mysql_connector.tar.gz && \
   curl -L -o /tmp/mssql-jdbc.jre8.jar "https://github.com/Microsoft/mssql-jdbc/releases/download/v${MSSQL_JDBC_VERSION}/mssql-jdbc-${MSSQL_JDBC_VERSION}.jre8.jar" \
       && cp /tmp/mssql-jdbc.jre8.jar ${PDI_HOME}/lib/mssql-jdbc.jre8.jar \
       && cp /tmp/mssql-jdbc.jre8.jar ${CATALINA_HOME}/lib/mssql-jdbc.jre8.jar \
       && rm -f /tmp/mssql-jdbc.jre8.jar

# ADD ./kettle-scheduler ./webapps/km


