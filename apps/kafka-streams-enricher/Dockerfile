FROM maven:3.9-eclipse-temurin-17 as build
WORKDIR /src
COPY pom.xml .
COPY src ./src
RUN mvn -q -DskipTests package

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /src/target/streams-enricher-*.jar /app/app.jar
ENV JAVA_OPTS=""
CMD ["bash","-lc","java $JAVA_OPTS -jar /app/app.jar"]
