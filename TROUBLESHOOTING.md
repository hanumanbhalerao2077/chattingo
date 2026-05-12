# 🔧 Troubleshooting Guide

## Quick Reference: Common Issues and Solutions

---

## Docker & Docker Compose Issues

### Docker daemon not running

**Symptoms:**
```
Cannot connect to Docker daemon at unix:///var/run/docker.sock
```

**Solutions:**

**macOS:**
```bash
# Start Docker Desktop or use:
open -a Docker
```

**Linux:**
```bash
# Check if Docker service is running
sudo systemctl status docker

# Start Docker
sudo systemctl start docker

# Enable auto-start
sudo systemctl enable docker
```

**Windows:**
- Open Docker Desktop from Start Menu
- Wait for Docker to initialize

---

### Port already in use

**Symptoms:**
```
Error response from daemon: driver failed programming external connectivity
ERROR: driver failed programming external connectivity on endpoint
Bind for 0.0.0.0:8080 failed: port is already allocated
```

**Solutions:**

**Find process using port:**
```bash
# Linux/macOS
lsof -i :8080      # Backend
lsof -i :3306      # MySQL
lsof -i :80        # Frontend

# Windows (PowerShell)
netstat -ano | findstr :8080
```

**Kill the process:**
```bash
# Linux/macOS
kill -9 <PID>

# Windows (PowerShell)
Stop-Process -Id <PID> -Force
```

**Or change port in docker-compose.yml:**
```yaml
services:
  backend:
    ports:
      - "8081:8080"  # Changed from 8080:8080
```

---

### Docker Compose configuration error

**Symptoms:**
```
yaml.scanner.ScannerError: mapping values are not allowed here
ERROR: yaml.parser.ParserError: expected <block end>
```

**Solutions:**

**Validate docker-compose.yml syntax:**
```bash
docker-compose config

# If syntax error shown, check for:
# - Incorrect indentation (use spaces, not tabs)
# - Missing colons after keys
# - Unclosed quotes
# - Incorrect YAML structure
```

**Common YAML mistakes:**
```yaml
# ❌ Wrong - using tabs
	services:
	  backend:
	    image: ...

# ✓ Correct - using 2 spaces
services:
  backend:
    image: ...

# ❌ Wrong - missing colon
services
  backend:

# ✓ Correct
services:
  backend:
```

---

### Docker images won't build

**Symptoms:**
```
ERROR: failed to solve with frontend dockerfile.v0
error getting credentials - err: exit status 1
```

**Solutions:**

**Clear Docker cache and rebuild:**
```bash
# Remove all images
docker-compose down -v

# Rebuild without cache
docker-compose build --no-cache

# Check build output for specific errors
docker-compose build --progress=plain
```

**Check Dockerfile syntax:**
```bash
# Lint Dockerfile
docker run --rm -i hadolint/hadolint < backend/Dockerfile
docker run --rm -i hadolint/hadolint < frontend/Dockerfile
```

**Increase Docker disk space:**
```bash
# macOS
# Docker preferences → Resources → Disk Image Size

# Linux
docker system df  # Check usage
docker system prune -a  # Clean up unused images
```

---

## Database Issues

### MySQL connection refused

**Symptoms:**
```
ERROR: Access denied for user 'root'@'localhost'
Connection refused
Can't connect to MySQL server on 'localhost'
```

**Solutions:**

**Check MySQL container is running:**
```bash
docker-compose ps mysql

# View MySQL logs
docker-compose logs mysql
```

**Verify credentials in .env:**
```bash
# Check connection parameters
echo $SPRING_DATASOURCE_URL
echo $SPRING_DATASOURCE_USERNAME
echo $SPRING_DATASOURCE_PASSWORD
```

**Connect to MySQL container:**
```bash
# Access MySQL CLI
docker-compose exec mysql mysql -u root -p
# When prompted for password, enter: root (or your MYSQL_ROOT_PASSWORD)

# List databases
SHOW DATABASES;

# Use chattingo database
USE chattingo_db;

# Show tables
SHOW TABLES;
```

**Reinitialize database:**
```bash
# Drop and recreate
docker-compose exec mysql mysql -u root -p
mysql> DROP DATABASE chattingo_db;
mysql> CREATE DATABASE chattingo_db;
mysql> EXIT;

# Run init script
docker-compose exec mysql mysql -u root -p chattingo_db < init-db.sql
```

---

### Database tables not created

**Symptoms:**
```
Table 'chattingo_db.user' doesn't exist
```

**Solutions:**

**Run initialization script manually:**
```bash
# Option 1: Using docker-compose
docker-compose exec mysql mysql -u root -p chattingo_db < init-db.sql

# Option 2: Copy script into container
docker cp init-db.sql chattingo-db:/tmp/
docker-compose exec mysql mysql -u root -p chattingo_db < /tmp/init-db.sql

# Option 3: Manual creation
docker-compose exec mysql mysql -u root -p
mysql> USE chattingo_db;
mysql> SOURCE /docker-entrypoint-initdb.d/init-db.sql;
```

**Check Hibernate auto-generation:**
```properties
# In backend/.env ensure:
SPRING_JPA_HIBERNATE_DDL_AUTO=update
# Not: validate (which prevents table creation)
```

**Verify schema creation:**
```bash
# Connect and check
docker-compose exec mysql mysql -u chattingo_user -p chattingo_db
mysql> SHOW TABLES;
mysql> DESCRIBE user;
mysql> SHOW TABLE STATUS;
```

---

## Backend Issues

### Backend won't start

**Symptoms:**
```
ERROR: Exception encountered during context initialization - cancelling refresh attempt
Application run failed
```

**Solutions:**

**View detailed error logs:**
```bash
docker-compose logs -f backend

# Or for more context
docker-compose logs backend | tail -100
```

**Common backend errors:**

1. **Database connection error:**
   ```
   SQL error: Cannot get a connection
   -> Check MySQL is running: docker-compose ps mysql
   -> Check credentials in .env
   -> Check SPRING_DATASOURCE_URL format
   ```

2. **Port already in use:**
   ```
   Address already in use
   -> Kill process on port 8080 (see Port already in use section)
   ```

3. **Java version mismatch:**
   ```
   Unsupported class-file format
   -> Ensure Java 17+ is in Dockerfile
   ```

4. **Out of memory:**
   ```
   Java.lang.OutOfMemoryError
   -> Increase JVM heap in docker-compose.yml:
      environment:
        - JAVA_OPTS=-Xmx1g -Xms512m
   ```

### JWT authentication errors

**Symptoms:**
```
Invalid JWT token
Authorization header missing
```

**Solutions:**

**Generate new JWT secret:**
```bash
# macOS/Linux
openssl rand -base64 64

# Windows (PowerShell)
[System.Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(48))

# Update .env
JWT_SECRET=your-new-secret-here

# Restart backend
docker-compose restart backend
```

**Verify JWT configuration:**
```bash
# Check if TOKEN_PROVIDER is configured
docker-compose exec backend grep -r "JWT" src/

# Test authentication endpoint
curl -X POST http://localhost:8080/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

---

### Backend API returns 401 Unauthorized

**Symptoms:**
```
Status: 401 Unauthorized
Unauthorized request
```

**Solutions:**

**Check token is being sent:**
```bash
# Verify Authorization header
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8080/api/chats

# Get token first
curl -X POST http://localhost:8080/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

**Verify CORS configuration:**
```bash
# Test CORS headers
curl -H "Origin: http://localhost:3000" \
     -H "Access-Control-Request-Method: POST" \
     -H "Access-Control-Request-Headers: Content-Type" \
     -X OPTIONS http://localhost:8080/api/chats -v
```

---

## Frontend Issues

### Frontend won't start

**Symptoms:**
```
npm ERR! code ELIFECYCLE
Error: npm start failed
Cannot find module '@mui/material'
```

**Solutions:**

**Reinstall dependencies:**
```bash
cd frontend

# Clear npm cache
npm cache clean --force

# Delete node_modules
rm -rf node_modules package-lock.json
# On Windows: rmdir /s /q node_modules

# Reinstall
npm install
```

**Check Node version:**
```bash
node -v  # Should be v18+
npm -v   # Should be 8+

# Upgrade Node if needed
# Download from nodejs.org or use:
nvm install 18  # macOS/Linux
choco upgrade nodejs  # Windows
```

**Clear browser cache:**
```bash
# Hard refresh in browser: Ctrl+Shift+Delete
# Or disable cache in DevTools
```

---

### Frontend can't connect to backend

**Symptoms:**
```
CORS error in console
Failed to fetch
Network error: Connection refused
```

**Solutions:**

**Check REACT_APP_API_URL:**
```bash
# In frontend/.env.development.local
cat frontend/.env.development.local

# Should show:
# REACT_APP_API_URL=http://localhost:8080

# If empty or wrong, update it
echo "REACT_APP_API_URL=http://localhost:8080" > frontend/.env.development.local
```

**Verify backend is running:**
```bash
# Check if backend is accessible
curl http://localhost:8080/auth

# If fails, restart backend
docker-compose restart backend
```

**Check CORS headers:**
```bash
# Verify CORS is configured
curl -H "Origin: http://localhost:3000" -X OPTIONS http://localhost:8080/api/chats -v
```

**Check browser DevTools:**
1. Open DevTools (F12)
2. Go to Network tab
3. Make a request to backend
4. Check response headers for CORS headers:
   - `Access-Control-Allow-Origin: http://localhost:3000`
   - `Access-Control-Allow-Methods: GET,POST,PUT,DELETE,OPTIONS`

---

### WebSocket connection fails

**Symptoms:**
```
WebSocket connection to 'ws://localhost:8080/ws' failed
STOMP ERROR
```

**Solutions:**

**Check WebSocket endpoint:**
```bash
# Verify endpoint is accessible
curl -i -N \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  http://localhost:8080/ws

# Should return 101 Switching Protocols
```

**Check WebSocket configuration:**
```bash
# In WebSocketConfig.java, ensure:
# - @EnableWebSocketMessageBroker is present
# - registerStompEndpoints("/ws") is configured
# - setAllowedOrigins includes frontend origin
```

**Check browser console:**
1. Open DevTools (F12)
2. Go to Console tab
3. Look for error messages
4. Check Network tab → WS filter for WebSocket connections

**Test from backend logs:**
```bash
docker-compose logs -f backend | grep -i websocket

# Should show connection messages
```

**Update WebSocket URL if needed:**
```javascript
// In frontend HomePage.jsx
const client = new Client({
  webSocketFactory: () => new SockJs(`${BASE_API_URL}/ws`),
  // ...
});
```

---

## Network & Connectivity Issues

### Services can't communicate

**Symptoms:**
```
Cannot connect from frontend to backend
Backend can't reach MySQL
Network error
```

**Solutions:**

**Check Docker network:**
```bash
# List networks
docker network ls

# Inspect chattingo network
docker network inspect chattingo_chattingo-network

# All containers should be on the same network
docker-compose ps
```

**Verify service names:**
```bash
# Services should use container names for communication:
# mysql -> database service
# backend -> backend service
# frontend -> frontend service

# Check in docker-compose.yml services section
```

**Test connectivity between containers:**
```bash
# From backend to MySQL
docker-compose exec backend ping mysql

# From frontend to backend
docker-compose exec frontend curl http://backend:8080/auth

# From backend to test outside
docker-compose exec backend curl http://google.com
```

---

## Performance Issues

### High CPU usage

**Symptoms:**
```
Docker container using 100% CPU
Application slow
```

**Solutions:**

**Check resource usage:**
```bash
docker stats

# Identify which container is using CPU
docker-compose logs -f backend | head -50
```

**Increase allocated resources:**
```yaml
# In docker-compose.yml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

**Optimize Java settings:**
```bash
# Adjust JVM heap size
environment:
  - JAVA_OPTS=-Xms512m -Xmx1g -XX:+UseG1GC
```

---

### High memory usage

**Symptoms:**
```
Out of memory error
Container killed
Memory: 100%
```

**Solutions:**

**Check memory usage:**
```bash
docker stats

# See which container is using memory
docker-compose exec backend ps aux | head -20
```

**Increase Docker memory:**
```bash
# Docker Desktop preferences:
# Settings → Resources → Memory: increase to 4GB or more
```

**Optimize application:**
```yaml
# Increase heap size
environment:
  - JAVA_OPTS=-Xms512m -Xmx1g
```

**Clean up Docker:**
```bash
# Remove unused containers and images
docker system prune -a

# Remove old volumes
docker volume prune

# Remove stopped containers
docker-compose down -v
docker-compose up -d
```

---

## Disk Space Issues

### Docker using too much disk

**Symptoms:**
```
No space left on device
Docker: Error response from daemon
```

**Solutions:**

**Check disk usage:**
```bash
# Overall usage
df -h

# Docker specific
docker system df

# Verbose breakdown
docker system df -v
```

**Clean up Docker:**
```bash
# Remove dangling images (safe)
docker image prune

# Remove all unused images (careful!)
docker image prune -a

# Remove all unused volumes
docker volume prune

# Full cleanup
docker system prune -a --volumes
```

**Clear application data:**
```bash
# Remove database volumes
docker-compose down -v

# Rebuild and restart
docker-compose up -d
```

---

## Debugging & Logging

### Enable debug logging

**Backend:**
```properties
# In backend/.env
LOGGING_LEVEL_ROOT=DEBUG
LOGGING_LEVEL_COM_CHATTINGO=DEBUG
SPRING_JPA_SHOW_SQL=true
```

**Frontend:**
```javascript
// In frontend/src/App.js or relevant component
const DEBUG = true;
if (DEBUG) console.log('Debug info:', data);
```

### Collect logs for troubleshooting

```bash
# Collect all logs
docker-compose logs > logs.txt

# Specific service logs
docker-compose logs backend > backend.log
docker-compose logs mysql > database.log
docker-compose logs frontend > frontend.log

# Real-time logs
docker-compose logs -f --tail=100

# Since specific time
docker-compose logs --since 2024-01-15T10:00:00
```

### Monitor container health

```bash
# Check health status
docker-compose ps

# Inspect health details
docker inspect chattingo-backend | grep -A 10 Health

# View health check logs
docker-compose logs -f backend | grep -i health
```

---

## Getting Further Help

### Resources
- [Docker Documentation](https://docs.docker.com/)
- [Spring Boot Troubleshooting](https://spring.io/guides)
- [React Documentation](https://react.dev)
- [MySQL Documentation](https://dev.mysql.com/doc/)

### Ask for Help
1. **GitHub Issues**: Report bugs or issues
2. **GitHub Discussions**: Ask questions
3. **Stack Overflow**: Tag with docker, spring-boot, react
4. **Docker Community**: [Docker Community Forums](https://forums.docker.com/)

### Before asking
1. Run `docker-compose logs -f` to get error messages
2. Try the solutions in this guide
3. Provide complete error messages and logs
4. Describe steps to reproduce the issue
5. Include system information (OS, versions, etc.)

---

<div align="center">

**Can't find your issue here?**

Create an issue on [GitHub Issues](https://github.com/yourusername/chattingo/issues)
with error messages and logs. We're happy to help!

</div>
