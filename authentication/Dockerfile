FROM openjdk:21-jre-slim
WORKDIR /app
COPY target/nervus-authentication-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]