FROM openjdk:8-jdk-slim

ARG MAVEN_VERSION=3.6.0
ARG USER_HOME_DIR="/root"
ARG APP_DIR="/app"
ARG TABBYXL_VERSION="v1.0.4"
ARG DATA_URL="https://data.mendeley.com/datasets/ydcr7mcrtp/5/files/6c347821-65c2-46ab-9b43-35d8c7dccf31/tabbyxl-dataset-v5.zip?dl=1"
ARG GITHUB_URL="https://github.com/tabbydoc/tabbyxl/archive/${TABBYXL_VERSION}.tar.gz"
ARG SHA=fae9c12b570c3ba18116a4e26ea524b29f7279c17cbaadc3326ca72927368924d9131d11b9e851b8dc9162228b6fdea955446be41207a5cfc61283dd8a561d2f
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN apt-get update && \
    apt-get install -y \
      curl procps \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn 
  
RUN mkdir ${APP_DIR} \
  && curl -fsSL -o /tmp/tabbyxl.tar.gz ${GITHUB_URL} \ 
  && tar -xzf /tmp/tabbyxl.tar.gz -C ${APP_DIR} --strip-components=1 \ 
  && curl -fsSL -o /tmp/tabbyxl-dataset-v5.zip ${DATA_URL} \
  && unzip /tmp/tabbyxl-dataset-v5.zip -d ${APP_DIR}


ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

WORKDIR $APP_DIR

RUN mvn clean install

CMD java -jar /app/target/TabbyXL-1.0.4-jar-with-dependencies.jar -input /app/tabbyxl-dataset-v5/data/tables.xlsx -ruleset /app/tabbyxl-dataset-v5/results/crl2j/rules.crl -ignoreSuperscript true -useCellText false -debuggingMode false -output /app/tabbyxl-dataset-v5/results/crl2j/extracted -useShortNames true
