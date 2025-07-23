FROM openjdk:21-jre-slim
WORKDIR /app
COPY target/nervus-authentication-0.0.1-SNAPSHOT.jar app.jar
COPY src/main/resources/data.sql data.sql
ENTRYPOINT ["java", "-jar", "app.jar"]

