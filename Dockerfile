FROM openjdk:8-jdk-alpine
USER app:app
COPY api_serve/target/api_serve-0.0.1-SNAPSHOT.jar app.JAR
RUN ['java', '-jar', 'aPP.JAR']
EXPOSE 8080 