# Simple WordPress Docker Setup

## **Quick Start:**

1. **Copy project to your VM**
2. **Run:** `docker compose up -d`
3. **Open:** `http://YOUR-VM-IP`
4. **Done!**

## **VM Setup:**

```bash
# Install Docker
sudo apt update
sudo apt install docker.io docker-compose
sudo systemctl start docker
sudo usermod -aG docker $USER

# Allow HTTP traffic
sudo ufw allow 80
sudo ufw allow 22

# Deploy
git clone your-repo
cd your-project
docker compose up -d
```

## **Access Your Site:**

- **URL:** `http://YOUR-VM-IP`
- **Admin:** `http://YOUR-VM-IP/wp-admin`
- **Complete WordPress setup**

That's it! 🚀
