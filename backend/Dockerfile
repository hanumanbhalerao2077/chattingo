# ============================================
# Stage 1: Build the application
# ============================================
FROM maven:3.9.5-eclipse-temurin-17 AS builder

WORKDIR /build

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:resolve

# Copy source code and build the application
COPY src ./src
RUN mvn clean package -DskipTests -q

# ============================================
# Stage 2: Runtime image
# ============================================
FROM eclipse-temurin:17.0.9_9-jre-alpine

WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /build/target/chattingo-0.0.1-SNAPSHOT.jar app.jar

# Create a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Expose the port that Spring Boot uses
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD java -cp app.jar org.springframework.boot.loader.JarLauncher --version || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
