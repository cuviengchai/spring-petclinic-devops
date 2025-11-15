#!/bin/bash

# Setup SonarQube webhook for Jenkins
# Replace YOUR_TOKEN with your actual SonarQube token

SONAR_URL="http://localhost:9000"
SONAR_TOKEN="squ_c2877eb95ed55b2c4a2cfcb56ab1730343b08174"  # Replace with your token
JENKINS_URL="http://jenkins:8080/sonarqube-webhook/"

echo "Creating SonarQube webhook for Jenkins..."

# Create webhook
curl -u ${SONAR_TOKEN}: -X POST "${SONAR_URL}/api/webhooks/create" \
  -d "name=Jenkins" \
  -d "url=${JENKINS_URL}"

echo ""
echo "Webhook created successfully!"
echo ""
echo "Webhook details:"
echo "  Name: Jenkins"
echo "  URL: ${JENKINS_URL}"
echo ""
echo "You can verify at: ${SONAR_URL}/admin/webhooks"