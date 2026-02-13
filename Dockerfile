# ---------- Base image ----------
FROM eclipse-temurin:17-jre-jammy

# ---------- Build arguments ----------
ARG NEXUS_URL
ARG REPO
ARG GROUP_ID
ARG ARTIFACT_ID
ARG VERSION
ARG NEXUS_USER
ARG NEXUS_PASSWORD

# ---------- App directory ----------
WORKDIR /app

# ---------- Download JAR from Nexus (Authenticated) ----------
RUN apt-get update && apt-get install -y curl && \
    curl -u ${NEXUS_USER}:${NEXUS_PASSWORD} -f \
    ${NEXUS_URL}/repository/${REPO}/${GROUP_ID}/${ARTIFACT_ID}/${VERSION}/${ARTIFACT_ID}-${VERSION}.jar \
    -o app.jar && \
    apt-get remove -y curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ---------- Expose app port ----------
EXPOSE 8080

# ---------- Run application ----------
ENTRYPOINT ["java", "-jar", "app.jar"]

