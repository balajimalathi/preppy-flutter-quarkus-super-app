# =========================================================================
# Preppy backend — Quarkus JVM-mode image
# =========================================================================
# Build (multi-stage):
#   docker build -t preppy/backend:dev -f backend/Dockerfile backend
# Run:
#   docker run --rm -p 8080:8080 --env-file infra/.env preppy/backend:dev
# =========================================================================

# ---- 1. Build stage ------------------------------------------------------
FROM eclipse-temurin:17-jdk AS build

WORKDIR /workspace

COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN ./mvnw -B -q dependency:go-offline

COPY src/ src/
RUN ./mvnw -B -q package -DskipTests

# ---- 2. Runtime stage ----------------------------------------------------
FROM eclipse-temurin:17-jre AS runtime

ENV LANG=en_US.UTF-8 \
    JAVA_OPTS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"

WORKDIR /app

COPY --from=build /workspace/target/quarkus-app/lib/ ./lib/
COPY --from=build /workspace/target/quarkus-app/*.jar ./
COPY --from=build /workspace/target/quarkus-app/app/ ./app/
COPY --from=build /workspace/target/quarkus-app/quarkus/ ./quarkus/

EXPOSE 8080

USER 1001
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar quarkus-run.jar"]
