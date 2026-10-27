# syntax=docker/dockerfile:1
FROM eclipse-temurin:21-jdk AS build
WORKDIR /src
COPY gradlew settings.gradle.kts build.gradle.kts ./
COPY gradle gradle
RUN ./gradlew --no-daemon dependencies > /dev/null 2>&1 || true
COPY src src
RUN ./gradlew --no-daemon bootJar -x test

FROM eclipse-temurin:21-jre
RUN useradd --system --uid 10001 --create-home darman && mkdir -p /data/private-storage && chown -R darman /data
WORKDIR /app
COPY --from=build /src/build/libs/*.jar app.jar
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
ENV DARMAN_STORAGE_PATH=/data/private-storage \
    JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=70 -XX:+UseSerialGC"
EXPOSE 8080
# PORT is injected by hosting platforms (Render uses 10000); defaults to 8080 locally.
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s CMD ["sh","-c","exec 3<>/dev/tcp/127.0.0.1/${PORT:-8080} && printf 'GET /actuator/health/readiness HTTP/1.0\\r\\n\\r\\n' >&3 && grep -q UP <&3"]
ENTRYPOINT ["/app/docker-entrypoint.sh"]
