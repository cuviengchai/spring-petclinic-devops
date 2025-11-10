FROM eclipse-temurin:21-jdk

USER root
RUN apt-get update && apt-get install -y \
    build-essential cmake python3 python3-pip git curl \
 && rm -rf /var/lib/apt/lists/*