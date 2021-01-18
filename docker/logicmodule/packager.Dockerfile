FROM maven:3.6.1-jdk-8-alpine
WORKDIR /javaclay/
COPY ./javaclay/pom.xml /javaclay/pom.xml
RUN mvn -B -DskipTests=true dependency:resolve dependency:resolve-plugins && \
    mvn de.qaware.maven:go-offline-maven-plugin:resolve-dependencies
COPY ./javaclay/src /javaclay/src
COPY ./javaclay/META-INF /javaclay/META-INF
RUN mvn -o package -DskipTests=true -Dmaven.javadoc.skip=true -B -V

