# Build stage
FROM openjdk:21-slim AS builder
WORKDIR /build
COPY . .
RUN ./mvnw clean package -DskipTests

# Run stage
FROM openjdk:21-slim
WORKDIR /app
COPY --from=builder /build/target/*.jar app.jar

ENV SPRING_DATASOURCE_URL=jdbc:postgresql://postgre:5432/tukoo
ENV SPRING_DATASOURCE_USERNAME=postgres
ENV SPRING_DATASOURCE_PASSWORD=mochuelo

# Expose the application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]