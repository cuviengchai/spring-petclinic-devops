#!/bin/bash

# Setup script for SonarQube integration
# Run this after starting docker-compose

echo "Setting up SonarQube..."

# Wait for SonarQube to be ready
echo "Waiting for SonarQube to start (this may take a minute)..."
until curl -s http://localhost:9000/api/system/status | grep -q '"status":"UP"'; do
    echo "Waiting for SonarQube..."
    sleep 5
done

echo "SonarQube is up!"

# Default credentials
SONAR_URL="http://localhost:9000"
SONAR_USER="admin"
SONAR_PASS="qazxswedcR@1"

# Create a project token
echo "Creating SonarQube token..."
TOKEN_RESPONSE=$(curl -s -u ${SONAR_USER}:${SONAR_PASS} -X POST \
  "${SONAR_URL}/api/user_tokens/generate?name=jenkins-token")

SONAR_TOKEN=$(echo $TOKEN_RESPONSE | grep -o '"token":"[^"]*' | grep -o '[^"]*$')

if [ -z "$SONAR_TOKEN" ]; then
    echo "Failed to create token. You may need to change the default password first."
    echo "1. Go to http://localhost:9000"
    echo "2. Login with admin/admin"
    echo "3. Change the password when prompted"
    echo "4. Run this script again"
    exit 1
fi

echo ""
echo "=========================================="
echo "SonarQube Setup Complete!"
echo "=========================================="
echo "SonarQube URL: ${SONAR_URL}"
echo "SonarQube Token: ${SONAR_TOKEN}"
echo ""
echo "Next steps:"
echo "1. Go to Jenkins: http://localhost:8080"
echo "2. Navigate to: Manage Jenkins > System"
echo "3. Add SonarQube Server:"
echo "   - Name: SonarQube"
echo "   - Server URL: http://sonarqube:9000"
echo "   - Server authentication token: ${SONAR_TOKEN}"
echo ""
echo "4. Add the token as a Jenkins credential:"
echo "   - Go to: Manage Jenkins > Credentials"
echo "   - Add new Secret Text credential"
echo "   - Secret: ${SONAR_TOKEN}"
echo "   - ID: sonar-token"
echo "=========================================="