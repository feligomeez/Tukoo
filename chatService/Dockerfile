FROM openjdk:21-slim AS builder
WORKDIR /build
COPY . .
RUN ./mvnw clean package -DskipTests

# Run stage
FROM openjdk:21-slim
WORKDIR /app
COPY --from=builder /build/target/*.jar app.jar


# Expose the application port
EXPOSE 8084

# Run the application
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]