# ---------- Base image ----------
FROM eclipse-temurin:17-jre-jammy

# ---------- Arguments ----------
ARG NEXUS_URL=http://13.126.176.194:32081
ARG REPO=maven-releases
ARG GROUP_ID=com/example
ARG ARTIFACT_ID=java-sonar-demo
ARG VERSION=1.0

# ---------- App directory ----------
WORKDIR /app

# ---------- Download JAR from Nexus ----------
RUN apt-get update && apt-get install -y curl && \
    curl -f \
    ${NEXUS_URL}/repository/${REPO}/${GROUP_ID}/${ARTIFACT_ID}/${VERSION}/${ARTIFACT_ID}-${VERSION}.jar \
    -o app.jar && \
    apt-get remove -y curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ---------- Expose application port ----------
EXPOSE 8080

# ---------- Run application ----------
ENTRYPOINT ["java", "-jar", "app.jar"]

