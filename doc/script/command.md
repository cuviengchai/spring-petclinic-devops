# DevOps Final Project - Quick Start Commands

```bash
cd jenkins
docker-compose up 
```

## 📋 Service URLs After Setup

- **Jenkins**: http://localhost:8080
- **SonarQube**: http://localhost:9000 (admin/admin)
- **Grafana**: http://localhost:3000 (admin/admin)  
- **Prometheus**: http://localhost:9090
- **OWASP ZAP**: http://localhost:8090

## 📊 Check Services Status

```bash
# Check running containers
docker ps

# Check networks
docker network ls

# Check logs
docker logs jenkins
docker logs sonarqube
docker logs grafana
docker logs prometheus
```