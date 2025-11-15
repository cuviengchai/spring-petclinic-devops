FROM jenkins/jenkins:2.528.1-jdk21
USER root
RUN apt-get update && apt-get install -y lsb-release ca-certificates curl && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js (required for SonarQube JS/TS/CSS analysis)
ENV NODE_VERSION=22.x
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - && \
    apt-get install -y nodejs && \
    node --version && \
    npm --version && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install SonarQube Scanner
ENV SONAR_SCANNER_VERSION=6.2.1.4610
RUN curl -L https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-linux-x64.zip -o sonar-scanner.zip && \
    unzip sonar-scanner.zip -d /opt && \
    rm sonar-scanner.zip && \
    ln -s /opt/sonar-scanner-${SONAR_SCANNER_VERSION}-linux-x64/bin/sonar-scanner /usr/bin/sonar-scanner

USER jenkins
RUN jenkins-plugin-cli --plugins \
    "prometheus:819.v50953a_c560dd" \
    ssh-agent \
    sonar \
    jacoco
