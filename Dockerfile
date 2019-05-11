FROM tomcat:9-jre8-alpine as base

# Download PDI
ENV PDI_RELEASE=8.0 \
    PDI_VERSION=8.0.0.0-28\
    PDI_HOME=/data-integration
RUN apk add --update wget unzip && \
  mkdir -p /pentaho && \
  echo https://downloads.sourceforge.net/project/pentaho/Pentaho%20${PDI_RELEASE}/client-tools/pdi-ce-${PDI_VERSION}.zip | xargs wget --progress=dot:giga -qO- -O tmp.zip && \
  unzip -q tmp.zip -d /pentaho && \
  mv /pentaho/data-integration /data-integration && \
  rm -fr /pentaho && \
  rm -f tmp.zip && \
  apk del wget unzip 
RUN ln -s ${PDI_HOME}/plugins ${CATALINA_HOME} && \
    ln -s ${PDI_HOME}/system $CATALINA_HOME && \
    ln -s ${PDI_HOME}/simple-jndi ${CATALINA_HOME}

# Download JDBC
ENV MYSQL_JDBC_VERSION=8.0.16
ENV MSSQL_JDBC_VERSION=7.2.2
# https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.16.tar.gz
# https://github.com/microsoft/mssql-jdbc/releases/download/v7.2.2/mssql-jdbc-7.2.2.jre8.jar
RUN apk add --update curl && curl -L -o /tmp/mysql_connector.tar.gz "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_JDBC_VERSION}.tar.gz" \
       && tar -zxvf /tmp/mysql_connector.tar.gz -C ${CATALINA_HOME}/lib/ "mysql-connector-java-${MYSQL_JDBC_VERSION}/mysql-connector-java-${MYSQL_JDBC_VERSION}.jar" --strip-components 1 \
       && cp ${CATALINA_HOME}/lib/mysql-connector-java-${MYSQL_JDBC_VERSION}.jar ${PDI_HOME}/lib/ \
       && rm /tmp/mysql_connector.tar.gz \
    && curl -L -o /tmp/mssql-jdbc-${MSSQL_JDBC_VERSION}.jre8.jar "https://github.com/Microsoft/mssql-jdbc/releases/download/v${MSSQL_JDBC_VERSION}/mssql-jdbc-${MSSQL_JDBC_VERSION}.jre8.jar" \
       && cp /tmp/mssql-jdbc-${MSSQL_JDBC_VERSION}.jre8.jar ${PDI_HOME}/lib/ \
       && cp /tmp/mssql-jdbc-${MSSQL_JDBC_VERSION}.jre8.jar ${CATALINA_HOME}/lib/ \
       && rm -f /tmp/mssql-jdbc-${MSSQL_JDBC_VERSION}.jre8.jar \
       && apk del curl

FROM maven:3.5.0-jdk-8-alpine as builder
# add pom.xml and source code
ADD ./pom.xml pom.xml
ADD ./src src/
# package war
RUN mvn clean package

FROM base
COPY --from=builder ./kettle-scheduler.war ${CATALINA_HOME}/webapps/km.war