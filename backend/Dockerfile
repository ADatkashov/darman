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
USER darman
WORKDIR /app
COPY --from=build /src/build/libs/*.jar app.jar
ENV DARMAN_STORAGE_PATH=/data/private-storage \
    JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75"
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s CMD ["sh","-c","exec 3<>/dev/tcp/127.0.0.1/8080 && printf 'GET /actuator/health/readiness HTTP/1.0\\r\\n\\r\\n' >&3 && grep -q UP <&3"]
ENTRYPOINT ["java","-jar","/app/app.jar"]
