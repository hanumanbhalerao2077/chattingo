# 🚀 Deployment Guide for Hostinger VPS

## Complete Guide to Deploy Chattingo on Hostinger VPS with Jenkins

---

## Table of Contents
1. [Hostinger VPS Setup](#hostinger-vps-setup)
2. [Installing Jenkins](#installing-jenkins)
3. [Configuring Jenkins Pipeline](#configuring-jenkins-pipeline)
4. [Setting Up Domain & SSL](#setting-up-domain--ssl)
5. [Automated Deployment](#automated-deployment)
6. [Monitoring & Maintenance](#monitoring--maintenance)

---

## Hostinger VPS Setup

### 1. Purchase and Configure VPS

#### Initial Setup in Hostinger Dashboard:
1. Log in to [Hostinger Control Panel](https://hpanel.hostinger.com)
2. Go to **VPS** → Click your VPS
3. Select **Ubuntu 22.04 LTS** (if not already installed)
4. Note your VPS **IP Address** and root **Password**
5. Use SSH client to connect

### 2. Initial VPS Configuration

```bash
# SSH into VPS
ssh root@YOUR_VPS_IP
# When prompted, enter the root password

# Update system
apt update && apt upgrade -y

# Set timezone
timedatectl set-timezone UTC

# Configure firewall
apt install -y ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp     # SSH
ufw allow 80/tcp     # HTTP
ufw allow 443/tcp    # HTTPS
ufw allow 8080/tcp   # Backend (optional, for direct access)
ufw --force enable
ufw status

# Create non-root user (recommended)
adduser chattingo_admin
usermod -aG sudo chattingo_admin

# Copy SSH key for new user (run this locally, not on VPS)
# ssh-copy-id -i ~/.ssh/id_rsa.pub chattingo_admin@YOUR_VPS_IP

# Test new user login
# ssh chattingo_admin@YOUR_VPS_IP
```

### 3. Install Docker and Docker Compose

```bash
# SSH as root or new user with sudo

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group (optional, for non-sudo docker commands)
sudo usermod -aG docker chattingo_admin
# Log out and log back in for changes to take effect

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

### 4. Prepare Application Directory

```bash
# Create application directory
sudo mkdir -p /opt/chattingo
sudo chown -R chattingo_admin:chattingo_admin /opt/chattingo
cd /opt/chattingo

# Clone repository
git clone https://github.com/yourusername/chattingo.git .
# Or if you haven't pushed yet, copy files via SCP/SFTP

# Create environment files
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env.development.local

# Edit for production values
nano backend/.env
nano frontend/.env.development.local
```

---

## Installing Jenkins

### 1. Install Java Runtime

```bash
# Jenkins requires Java 11 or higher
sudo apt install -y openjdk-17-jdk

# Verify
java -version
```

### 2. Install Jenkins

```bash
# Add Jenkins repository
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2024.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt-get update
sudo apt-get install -y jenkins

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Verify status
sudo systemctl status jenkins

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### 3. Configure Jenkins

1. **Access Jenkins Web UI:**
   - Open http://YOUR_VPS_IP:8081 (or port 8080 if 8081 not used)
   
2. **Initial Setup:**
   - Paste the admin password from above
   - Select "Install suggested plugins"
   - Create first admin user
   - Start using Jenkins

### 4. Install Required Jenkins Plugins

In Jenkins Dashboard:
1. **Manage Jenkins** → **Manage Plugins**
2. **Available** tab → Search for and install:
   - **Docker Pipeline** - Docker integration
   - **GitHub Integration** - GitHub webhook support
   - **SSH** - SSH Build Agent Support
   - **Email Extension Plugin** - Email notifications
   - **Blue Ocean** (Optional) - Better UI

3. After installation, restart Jenkins:
   ```bash
   sudo systemctl restart jenkins
   ```

---

## Configuring Jenkins Pipeline

### 1. Create GitHub Credentials

1. Go to **Manage Jenkins** → **Manage Credentials**
2. Click **Global credentials (unrestricted)**
3. Click **Add Credentials**
   - Kind: **Username with password**
   - Username: Your GitHub username
   - Password: [Generate GitHub Personal Access Token](https://github.com/settings/tokens)
   - ID: `github-credentials`

### 2. Create Docker Hub Credentials

1. Go to **Manage Jenkins** → **Manage Credentials**
2. Click **Global credentials (unrestricted)**
3. Click **Add Credentials**
   - Kind: **Username with password**
   - Username: Your Docker Hub username
   - Password: Your Docker Hub password/token
   - ID: `docker-hub-credentials`

### 3. Create SSH Credentials for VPS Deployment

1. Go to **Manage Jenkins** → **Manage Credentials**
2. Click **Global credentials (unrestricted)**
3. Click **Add Credentials**
   - Kind: **SSH Username with private key**
   - Username: `root` (or your VPS user)
   - Private Key: [Copy your SSH private key from ~/.ssh/id_rsa]
   - ID: `vps-ssh-key`

### 4. Create Secret Text Credentials

Create two more credentials:

**For VPS Host:**
1. Click **Add Credentials**
   - Kind: **Secret text**
   - Secret: `YOUR_VPS_IP` or domain
   - ID: `vps-host`

**For VPS User:**
1. Click **Add Credentials**
   - Kind: **Secret text**
   - Secret: `root` (or your VPS user)
   - ID: `vps-user`

### 5. Create Pipeline Job

1. **New Item** → Enter name: `chattingo`
2. Select **Pipeline** → Click OK
3. **Configure Pipeline:**

   **General Tab:**
   - Description: "Chattingo real-time chat application"
   - Check: "Discard old builds"
   - Days to keep builds: 7
   - Max # of builds: 10

   **Build Triggers Tab:**
   - Check: "GitHub hook trigger for GITScm polling"
   - This enables automated builds on GitHub push

   **Pipeline Tab:**
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: `https://github.com/yourusername/chattingo.git`
   - Credentials: Select `github-credentials`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`

4. Click **Save**

### 6. Setup GitHub Webhook (Optional - For Automated Builds)

If you want Jenkins to build automatically when you push code:

1. Go to your GitHub repository → **Settings** → **Webhooks** → **Add webhook**
2. **Payload URL**: `http://YOUR_VPS_IP:8080/github-webhook/`
3. **Content type**: `application/json`
4. **Events**: `Just the push event`
5. **Active**: Check this box
6. Click **Add webhook**

---

## Setting Up Domain & SSL

### 1. Point Domain to VPS

In your domain registrar (Hostinger, Namecheap, etc.):

1. Go to **DNS Records** or **Name Servers**
2. Create **A Record:**
   - Name: `@` (root) or `www`
   - Value: Your VPS IP
   - TTL: 3600

Example:
```
Type    Host    Value          TTL
A       @       YOUR_VPS_IP    3600
A       www     YOUR_VPS_IP    3600
```

### 2. Install SSL Certificate (Let's Encrypt)

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot certonly --standalone \
  -d your-domain.com \
  -d www.your-domain.com \
  -m your-email@example.com \
  --agree-tos \
  --non-interactive

# Verify certificate
sudo ls -la /etc/letsencrypt/live/your-domain.com/
```

### 3. Configure Nginx as Reverse Proxy

```bash
# Create Nginx configuration
sudo nano /etc/nginx/sites-available/chattingo

# Add this configuration:
```

```nginx
upstream backend {
    server backend:8080;
}

server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;
    
    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Root location
    root /opt/chattingo/frontend/build;
    index index.html;
    
    # Reverse proxy for API
    location /api/ {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # WebSocket proxy
    location /ws {
        proxy_pass http://backend/ws;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_read_timeout 86400;
    }
    
    # React app routing
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

```bash
# Enable configuration
sudo ln -s /etc/nginx/sites-available/chattingo /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Enable and start Nginx
sudo systemctl enable nginx
sudo systemctl start nginx
```

### 4. Auto-Renew SSL Certificate

```bash
# Certbot auto-renewal (runs daily via systemd)
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Test renewal
sudo certbot renew --dry-run
```

---

## Automated Deployment

### 1. Update Jenkinsfile Environment

Edit `Jenkinsfile` in your repository:

```groovy
environment {
    VPS_HOST = credentials('vps-host')
    VPS_USER = credentials('vps-user')
    VPS_SSH_KEY = credentials('vps-ssh-key')
    // ... other variables
}
```

### 2. Setup Deployment Script

Create `/opt/chattingo/deploy.sh` on VPS:

```bash
#!/bin/bash
set -e

echo "===== Starting Deployment ====="

# Navigate to app directory
cd /opt/chattingo

# Pull latest code
git pull origin main

# Update environment variables (if needed)
# (Don't overwrite production .env files)

# Rebuild images with new code
docker-compose build

# Start services
docker-compose up -d

# Wait for services
sleep 15

# Run health checks
echo "Running health checks..."
curl -f http://localhost:8080/health || exit 1
curl -f http://localhost/health || exit 1

echo "===== Deployment Complete ====="
```

```bash
# Make script executable
chmod +x /opt/chattingo/deploy.sh
```

### 3. Deploy from Jenkins

In Jenkins Pipeline (`Jenkinsfile`), update Deploy stage:

```groovy
stage('Deploy to VPS') {
    when {
        branch 'main'
    }
    steps {
        script {
            sshagent(['vps-ssh-key']) {
                sh '''
                    ssh -o StrictHostKeyChecking=no ${VPS_USER}@${VPS_HOST} \
                        "/opt/chattingo/deploy.sh"
                '''
            }
        }
    }
}
```

### 4. Trigger Deployment

**Option 1: Manual Trigger**
- Go to Jenkins → chattingo → Build Now

**Option 2: Automatic on GitHub Push**
- Push to main branch
- GitHub webhook triggers Jenkins
- Pipeline runs automatically

---

## Monitoring & Maintenance

### 1. Monitor Application Health

```bash
# SSH into VPS
ssh root@YOUR_VPS_IP

# Check container status
docker-compose ps

# View logs
docker-compose logs -f

# Check specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mysql

# Monitor resources
docker stats
```

### 2. Backup Database

```bash
# Create backup directory
mkdir -p /opt/chattingo/backups

# Backup database
docker-compose exec mysql mysqldump -u root -p chattingo_db > /opt/chattingo/backups/backup-$(date +%Y%m%d-%H%M%S).sql

# Or create automated backup (cron job)
# Edit crontab:
crontab -e

# Add line (backup daily at 2 AM):
0 2 * * * docker-compose -f /opt/chattingo/docker-compose.yml exec -T mysql mysqldump -u root -pPASSWORD chattingo_db > /opt/chattingo/backups/backup-$(date +\%Y\%m\%d).sql
```

### 3. Update Application

```bash
# Pull latest code
cd /opt/chattingo
git pull origin main

# Rebuild and restart
docker-compose up -d --build

# Verify deployment
docker-compose ps
```

### 4. View Jenkins Build History

- Jenkins Dashboard → chattingo → Build History
- Click on build number to see details
- View Console Output for logs

### 5. Troubleshoot Common Issues

**Container crashed:**
```bash
# View error logs
docker-compose logs backend
docker-compose logs mysql

# Restart container
docker-compose restart backend
```

**Out of disk space:**
```bash
# Check disk usage
df -h

# Clean up Docker
docker system prune -a
docker volume prune
```

**Database corruption:**
```bash
# Restore from backup
mysql -u root -p chattingo_db < /opt/chattingo/backups/backup-DATE.sql
```

### 6. Security Hardening

```bash
# Update system regularly
sudo apt update && sudo apt upgrade -y

# Disable root login via SSH
sudo nano /etc/ssh/sshd_config
# Set: PermitRootLogin no
sudo systemctl restart sshd

# Enable 2FA on GitHub account

# Rotate SSH keys regularly

# Monitor for suspicious activity
sudo tail -f /var/log/auth.log
sudo tail -f /var/log/nginx/error.log
```

---

## Verification Checklist

- [ ] VPS is running and accessible
- [ ] Docker and Docker Compose installed
- [ ] Jenkins is installed and running (port 8080)
- [ ] GitHub credentials added to Jenkins
- [ ] Docker Hub credentials added to Jenkins
- [ ] VPS SSH credentials added to Jenkins
- [ ] Pipeline job created and configured
- [ ] Jenkinsfile in main branch
- [ ] Domain points to VPS IP
- [ ] SSL certificate installed
- [ ] Nginx reverse proxy configured
- [ ] Application deployed and running
- [ ] Health checks passing
- [ ] Domain resolves correctly
- [ ] HTTPS working with valid certificate
- [ ] Real-time messaging working
- [ ] Database persisting data

---

## Production Monitoring URLs

After deployment, access:

- **Frontend**: https://your-domain.com
- **API Health**: https://your-domain.com/api/auth
- **Backend Direct**: https://your-domain.com:8080/health (if exposed)
- **Jenkins**: http://YOUR_VPS_IP:8080/

---

## Support & Troubleshooting

For issues during deployment:

1. **Check Logs**: `docker-compose logs -f`
2. **Verify Network**: `curl http://localhost:8080/auth`
3. **Check Disk Space**: `df -h`
4. **Restart Services**: `docker-compose restart`
5. **Review Jenkinsfile**: Ensure syntax is correct
6. **Check GitHub Webhook**: Settings → Webhooks

---

<div align="center">

**🎉 Congratulations! Your application is live on Hostinger VPS! 🎉**

**Next Steps:**
- Monitor application health
- Set up automated backups
- Enable email notifications
- Configure monitoring tools

</div>
