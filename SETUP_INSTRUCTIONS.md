# 🚀 Complete Setup & Installation Guide

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Quick Start (Docker)](#quick-start-docker-recommended)
3. [Local Development Setup](#local-development-setup)
4. [Production Deployment](#production-deployment)
5. [Troubleshooting](#troubleshooting)

---

## System Requirements

### Minimum System Requirements
- **CPU**: 2 cores
- **RAM**: 2GB minimum (4GB+ recommended)
- **Disk Space**: 10GB available
- **OS**: Linux (Ubuntu 20.04+), macOS 10.14+, or Windows 10+

### Software Prerequisites

#### For Docker Setup (Recommended)
- **Docker**: 20.10 or higher
- **Docker Compose**: 1.29 or higher
- **Git**: 2.30 or higher

#### For Local Development
- **Java**: JDK 17 or higher
- **Node.js**: 18 or higher
- **npm**: 8 or higher
- **MySQL**: 8.0 or higher
- **Git**: 2.30 or higher
- **Maven**: 3.9 or higher

### Installation Links
- [Docker Desktop](https://www.docker.com/products/docker-desktop) - All platforms
- [Docker (Linux)](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
- [Java 17 (Adoptium)](https://adoptium.net/)
- [Node.js 18](https://nodejs.org/)
- [MySQL Community Edition](https://dev.mysql.com/downloads/mysql/)
- [Git](https://git-scm.com/)
- [Maven](https://maven.apache.org/)

---

## Quick Start (Docker - Recommended)

### The Fastest Way to Run Chattingo (5 minutes)

```bash
# Step 1: Clone the repository
git clone https://github.com/yourusername/chattingo.git
cd chattingo

# Step 2: Create environment files
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env.development.local

# Step 3: Start all services with Docker Compose
docker-compose up -d

# Step 4: Wait for services to initialize
sleep 30

# Step 5: Verify all services are running
docker-compose ps

# Step 6: Access the application
# Frontend: http://localhost
# Backend:  http://localhost:8080
# Database: localhost:3306
```

### Verify Installation

```bash
# Check all containers are healthy
docker-compose ps

# View logs if needed
docker-compose logs -f

# Test backend is responding
curl http://localhost:8080/auth

# Test frontend is responding
curl http://localhost/health
```

### Stop Services

```bash
# Stop all services (preserves data)
docker-compose stop

# Stop and remove containers
docker-compose down

# Remove everything including volumes
docker-compose down -v
```

---

## Local Development Setup

### Complete Local Installation Guide

#### Step 1: Install System Dependencies

**macOS Installation:**
```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Java 17
brew install openjdk@17
sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk

# Add to PATH
echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Install Node.js
brew install node@18
brew link node@18

# Install MySQL
brew install mysql@8.0
brew services start mysql@8.0

# Verify installations
java -version
node -v
npm -v
mysql --version
```

**Ubuntu/Debian Installation:**
```bash
# Update package manager
sudo apt update && sudo apt upgrade -y

# Install Java 17
sudo apt install -y openjdk-17-jdk

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install MySQL
sudo apt install -y mysql-server

# Start MySQL service
sudo systemctl start mysql
sudo systemctl enable mysql

# Install Maven
sudo apt install -y maven

# Verify installations
java -version
node -v
npm -v
mysql --version
mvn -version
```

**Windows Installation:**

1. **Java 17:**
   - Download from [Adoptium.net](https://adoptium.net/)
   - Run installer and follow wizard
   - Verify: `java -version` in cmd

2. **Node.js 18:**
   - Download from [nodejs.org](https://nodejs.org/)
   - Run installer and follow wizard
   - Verify: `node -v` and `npm -v` in cmd

3. **MySQL 8.0:**
   - Download from [mysql.com](https://dev.mysql.com/downloads/mysql/)
   - Run installer and follow wizard
   - Start MySQL Service

4. **Maven:**
   - Download from [maven.apache.org](https://maven.apache.org/)
   - Extract to `C:\Program Files\Apache\maven`
   - Add to PATH: Set `MAVEN_HOME=C:\Program Files\Apache\maven`

#### Step 2: Clone Repository

```bash
# Clone the repository
git clone https://github.com/yourusername/chattingo.git
cd chattingo

# Verify directory structure
ls -la  # Unix/Linux/macOS
dir     # Windows
```

#### Step 3: Setup Database

```bash
# Connect to MySQL
mysql -u root

# In MySQL prompt:
CREATE DATABASE chattingo_db;
CREATE USER 'chattingo_user'@'localhost' IDENTIFIED BY 'chattingo_password';
GRANT ALL PRIVILEGES ON chattingo_db.* TO 'chattingo_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Initialize database with schema
mysql -u chattingo_user -p chattingo_db < init-db.sql
# When prompted, enter password: chattingo_password
```

#### Step 4: Configure Backend

```bash
cd backend

# Copy environment template
cp .env.example .env

# Generate JWT Secret
# macOS/Linux:
openssl rand -base64 64

# Windows (PowerShell):
[System.Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(48))

# Edit .env file with your generated secret
# nano .env  # or use your preferred editor
```

**Update .env with:**
```properties
JWT_SECRET=<your-generated-secret>
SPRING_DATASOURCE_URL=jdbc:mysql://localhost:3306/chattingo_db?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC
SPRING_DATASOURCE_USERNAME=chattingo_user
SPRING_DATASOURCE_PASSWORD=chattingo_password
SPRING_JPA_HIBERNATE_DDL_AUTO=update
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:80
SERVER_PORT=8080
```

#### Step 5: Start Backend

```bash
cd backend

# Build the project (first time only)
./mvnw clean install -DskipTests
# Or on Windows: mvnw.cmd clean install -DskipTests

# Run the application
./mvnw spring-boot:run
# Or on Windows: mvnw.cmd spring-boot:run

# You should see:
# Started ChattingoApplication in X seconds
```

**Backend is now running at: http://localhost:8080**

#### Step 6: Configure Frontend

```bash
cd frontend

# Copy environment template
cp .env.example .env.development.local

# Edit configuration (optional, defaults work fine)
# nano .env.development.local
```

**Update .env.development.local with:**
```
REACT_APP_API_URL=http://localhost:8080
REACT_APP_WS_URL=ws://localhost:8080/ws
```

#### Step 7: Install Frontend Dependencies

```bash
cd frontend

# Install npm dependencies
npm install

# This may take 2-3 minutes
```

#### Step 8: Start Frontend Development Server

```bash
cd frontend

# Start the development server
npm start

# Browser will automatically open at http://localhost:3000
# If not, manually navigate to http://localhost:3000
```

**Frontend is now running at: http://localhost:3000**

#### Step 9: Test the Application

1. Open http://localhost:3000 in your browser
2. Click "Sign Up"
3. Create an account:
   - Name: Test User 1
   - Email: test1@example.com
   - Password: password123
4. Click "Sign In" with these credentials
5. Create another account for testing:
   - Name: Test User 2
   - Email: test2@example.com
   - Password: password123
6. Create a chat between the two users
7. Send messages and verify real-time delivery

### Stopping Local Development

```bash
# Stop backend: Press Ctrl+C in the terminal running the backend
# Stop frontend: Press Ctrl+C in the terminal running the frontend
# Stop MySQL: 
#   macOS: brew services stop mysql@8.0
#   Linux: sudo systemctl stop mysql
#   Windows: Services → MySQL → Stop
```

---

## Production Deployment

### Prerequisites for Production
- Hostinger VPS with Ubuntu 22.04 LTS
- Minimum 2GB RAM, 20GB storage
- SSH access to VPS
- Domain name (optional but recommended)

### Deployment Steps

#### 1. Prepare VPS

```bash
# SSH into your VPS
ssh root@YOUR_VPS_IP

# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Git
apt install -y git

# Create application directory
mkdir -p /opt/chattingo
cd /opt/chattingo
```

#### 2. Clone Repository on VPS

```bash
cd /opt/chattingo

# Clone your repository
git clone https://github.com/yourusername/chattingo.git .

# Create .env files
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env.development.local

# Edit for production
nano backend/.env
nano frontend/.env.development.local
```

**Production .env values:**
```properties
# Backend .env
JWT_SECRET=<your-secure-random-key>
SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/chattingo_db?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC
SPRING_DATASOURCE_USERNAME=chattingo_user
SPRING_DATASOURCE_PASSWORD=<strong-password>
CORS_ALLOWED_ORIGINS=https://your-domain.com,https://www.your-domain.com
SERVER_PORT=8080
SPRING_PROFILES_ACTIVE=prod

# Database
MYSQL_ROOT_PASSWORD=<strong-root-password>
MYSQL_USER=chattingo_user
MYSQL_PASSWORD=<strong-password>
MYSQL_DATABASE=chattingo_db

# Frontend .env.development.local
REACT_APP_API_URL=https://your-domain.com
```

#### 3. Start Application on VPS

```bash
cd /opt/chattingo

# Build and start services
docker-compose up -d

# Wait for initialization
sleep 30

# Verify services
docker-compose ps

# Check logs
docker-compose logs -f backend
```

#### 4. Setup Domain & SSL (Optional)

```bash
# Install Certbot
apt install -y certbot python3-certbot-nginx

# Generate SSL certificate
certbot certonly --standalone -d your-domain.com -d www.your-domain.com

# Update Nginx configuration
# Add to /etc/nginx/sites-available/default:
# listen 443 ssl;
# ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
# ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

# Test Nginx configuration
nginx -t

# Reload Nginx
systemctl reload nginx

# Auto-renew SSL certificates
certbot renew --dry-run
```

#### 5. Verify Deployment

```bash
# Check application status
curl -f https://your-domain.com/health

# Check API
curl -f https://your-domain.com/api/auth

# View all logs
docker-compose logs

# Monitor resources
docker stats
```

### Backup & Maintenance

```bash
# Backup database
docker-compose exec mysql mysqldump -u root -p chattingo_db > backup.sql

# Restore from backup
cat backup.sql | docker-compose exec -T mysql mysql -u root -p chattingo_db

# Update application
cd /opt/chattingo
git pull origin main
docker-compose up -d --build

# View container logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mysql
```

---

## Troubleshooting

### Docker Issues

**Containers won't start:**
```bash
# Check docker daemon
docker ps

# Check docker-compose syntax
docker-compose config

# View error logs
docker-compose logs backend

# Rebuild images
docker-compose build --no-cache
docker-compose up -d
```

**Port already in use:**
```bash
# Find process using port
lsof -i :8080     # Backend
lsof -i :80       # Frontend
lsof -i :3306     # MySQL

# Kill process
kill -9 <PID>

# Or change ports in docker-compose.yml
```

### Database Issues

**Can't connect to database:**
```bash
# Check MySQL container logs
docker-compose logs mysql

# Connect to MySQL container
docker-compose exec mysql mysql -u root -p

# Check database exists
SHOW DATABASES;
USE chattingo_db;
SHOW TABLES;
```

**Schema not initialized:**
```bash
# Manually run init script
docker-compose exec mysql mysql -u root -p chattingo_db < init-db.sql

# Or connect and run SQL manually
docker-compose exec mysql mysql -u root -p
source /docker-entrypoint-initdb.d/init-db.sql;
```

### Backend Issues

**Startup fails:**
```bash
# Check logs
docker-compose logs -f backend

# Check if port 8080 is accessible
curl http://localhost:8080/auth

# Verify database connection
docker-compose exec backend curl http://mysql:3306
```

**JWT errors:**
```bash
# Generate new secret
openssl rand -base64 64

# Update .env
JWT_SECRET=new-secret

# Restart backend
docker-compose restart backend
```

### Frontend Issues

**Can't connect to backend:**
```bash
# Check API URL in browser console
# F12 → Console → Check for CORS errors

# Verify backend is running
curl http://localhost:8080/api/auth

# Check CORS configuration
curl -H "Origin: http://localhost:3000" \
     -H "Access-Control-Request-Method: GET" \
     -X OPTIONS http://localhost:8080/api/chats
```

**WebSocket connection fails:**
```bash
# Check WebSocket endpoint
curl -i -N \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  http://localhost:8080/ws

# Check browser console for STOMP errors
# Check network tab in browser DevTools
```

### Performance Issues

**Slow response times:**
```bash
# Check container resources
docker stats

# Increase RAM/CPU in docker-compose.yml:
# services:
#   backend:
#     deploy:
#       resources:
#         limits:
#           cpus: '2'
#           memory: 2G

# Rebuild and restart
docker-compose down
docker-compose up -d
```

**High memory usage:**
```bash
# Check logs for memory leaks
docker-compose logs backend | grep -i memory

# Restart services
docker-compose restart

# Increase JVM heap size
# Edit Dockerfile or add to docker-compose.yml:
# environment:
#   - JAVA_OPTS=-Xmx1g -Xms512m
```

### Getting Help

1. **Check Logs:**
   ```bash
   docker-compose logs -f [service-name]
   ```

2. **Visit Endpoints:**
   - Backend Health: http://localhost:8080/health
   - Frontend Health: http://localhost/health

3. **Test Connectivity:**
   ```bash
   docker-compose exec backend curl http://mysql:3306
   docker-compose exec frontend curl http://backend:8080
   ```

4. **Database Check:**
   ```bash
   docker-compose exec mysql mysql -u root -p chattingo_db
   SHOW TABLES;
   SELECT COUNT(*) FROM user;
   ```

5. **Ask for Help:**
   - GitHub Issues
   - Discord Server
   - Email Support

---

<div align="center">

**✨ You're all set! Start chatting on Chattingo! ✨**

Need help? Check the [main README](Readme.md) or [CONTRIBUTING.md](CONTRIBUTING.md)

</div>
