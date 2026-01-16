# DHBW CAS - Labor IT Sicherheit - Runde 3

Gruppenmitglieder:

- Jens Hausdorf
- Vitali Wiegandt

## Aufgabenstellung

Setzen Sie in der VM einen Server unter Verwendung geeigneter Werkzeuge und Technologien auf. Wählen Sie im Zweifelsfall die einfachere Realisierungsvariante, damit Sie nicht mit „Kanonen auf Spatzen schießen“. Die Webseite braucht neben der Grundfunktionalität für den beschriebenen Anwendungsfall keine echten oder gar sinnvolle Inhalte und ein ausgefeiltes Design zu haben, aber etwas Content in einigermaßen ansprechender Form (gerne KI-generiert) wäre nett, um einen realistischen Eindruck zu haben.

Überlegen Sie sich, wie das System (auf den verschiedenen Ebenen OS, Webserver, Anwendung) dem Schutzbedarf entsprechend abgesichert werden kann. Dokumentieren Sie, wie Sie zu Ihren Entscheidungen gelangt sind und (kurz, aber nachvollziehbar) wie Sie diese umgesetzt haben. Halten Sie fest, gegen welche Bedrohungen Ihre Maßnahmen wirken. Ggf. können Sie auch noch angeben, wie die Wirksamkeit der Maßnahmen überprüft werden kann.

**Allgemeine Regeln:**

- Arbeiten Sie mit den zur Verfügung gestellten Images und installieren/konfigurieren Sie dort alles Nötige. Eine Neuinstallation des Betriebssystems ist dabei nicht nötig oder vorgesehen. Zu Beginn erhalten Sie einen root-Zugang. Der Dozenten-Account (User „ts“ o.Ä.) muss auf den Systemen mit allen Rechten erhalten bleiben.
- Treffen Sie keine impliziten Annahmen über die Sicherheit des Ausgangssystems (es handelt sich um vorgefertigte Images), sondern prüfen Sie die notwendigen Kriterien selbst (bitte festhalten!) und nehmen Sie die nötigen Änderungen und Anpassungen vor.
- Für die VMs kann keine bestimmte Verfügbarkeit gewährleistet werden, Sie sind für Backups (bzw. die Reproduzierbarkeit Ihrer Konfigurationen) selbst verantwortlich.
- Jedes Team arbeitet eigenständig, die Teams dürfen sich während der Runde nicht untereinander austauschen oder Ergebnisse veröffentlichen. Zugriffe auf die Systeme anderer Teams sind unzulässig, sofern nicht explizit vom Dozenten gestattet.
- Die Systeme sind aus dem Internet erreichbar (ggf. wird dies eingeschränkt auf das CAS-VPN). Achten Sie daher darauf, dass Sie keine größeren Sicherheitslücken haben. Ausgehender Traffic sollte auf das beschränkt sein, was für die Lösung der Aufgabe erforderlich ist.
- Der Einsatz von KI zur Lösungsfindung und Erzeugung von Dummy-Content o.Ä. ist erlaubt, nicht aber für die Generierung von Text für die Dokumentation. Machen Sie die Verwendung entsprechender Tools bitte kennlich gemäß der Vorlage des CAS. Wie immer sind Sie in jedem Fall für die durch KI erzeugten Ergebnisse verantwortlich, haben diese und mögliche Quellen selbst zu prüfen.

**Bewertungskriterien:**

Sie sollen zeigen, wie sich die fachlichen und funktionalen Anforderungen sicher umsetzen lassen und Ihren Lösungsweg beschreiben. Bei der Bewertung wird u.a. geachtet auf

- Umfang der identifizierten Anforderungen/Bedrohungen
- Methodische Vorgehensweise
- Angemessenheit der technologischen Entscheidungen und Auswahl der Schutzmechanismen
- Nachvollziehbarkeit, Vollständigkeit, Verständlichkeit der Dokumentation (Test-Accounts bitte mit aufführen)
- Originalität

## Deployment

### Local Development (Windows)

For local development without SSL, you can use the local configuration:

1. Create a `.env` file with the required environment variables:

   ```bash
   WP_DB_PASSWORD=your_password_here
   MYSQL_ROOT_PASSWORD=your_root_password_here
   REDIS_PASSWORD=your_redis_password_here  # Optional, defaults to 'redis_password'
   ```

2. Start the containers with the local configuration:

   ```bash
   docker compose -f docker-compose.yml -f docker-compose.local.yml up -d
   ```

3. The application is accessible at `http://localhost` (HTTP only, no SSL).

4. Stop containers:
   ```bash
   docker compose down
   ```

**Note:** The local configuration (`docker-compose.local.yml` and `nginx/conf.d/default-local.conf`) does not use SSL and is intended for local development only.

### Production Deployment (Alma Linux VM)

For deployment on the production VM (alma-3.new.dhbw.it):

1. Establish SSH connection to the VM:

   ```bash
   ssh bohnenkopf@alma-3.new.dhbw.it
   ```

2. Clone or update the repository:

   ```bash
   git clone git@github.com:KxroShinigami/cas-ws25-laboritsicherheit-alma-runde3.git
   cd cas-ws25-laboritsicherheit-alma-runde3
   # or if already present:
   git pull
   # a deployment token with a passphrase is used:
   Enter passphrase for key '/home/bohnenkopf/.ssh/id_ed25519': <enter_passphrase>
   ```

3. Create `.env` file with production passwords:

   ```bash
   # Create a .env file with secure passwords
   WP_DB_PASSWORD=<secure_password>
   MYSQL_ROOT_PASSWORD=<secure_root_password>
   REDIS_PASSWORD=<secure_redis_password>  # Optional, defaults to 'redis_password'
   ```

4. Set up SSL certificates with Certbot (for initial setup):

   ```bash
   podman compose run --rm certbot certonly --webroot \
     --webroot-path=/var/www/certbot \
     --email admin@alma-3.new.dhbw.it \
     --agree-tos \
     --no-eff-email \
     -d alma-3.new.dhbw.it \
     -d www.alma-3.new.dhbw.it
   ```

5. Start containers:

   ```bash
   podman compose up -d
   ```

6. Check status:

   ```bash
   podman compose ps
   ```

7. View logs:
   ```bash
   podman compose logs -f
   ```

The application is accessible at `https://alma-3.new.dhbw.it`. The production configuration uses SSL/TLS with Let's Encrypt certificates and redirects all HTTP requests to HTTPS.

**Important:** Make sure the firewall on the VM allows incoming connections on ports 80 and 443.

### Redis Object Cache Setup

Redis is included in the docker-compose setup for use with the WordPress "Redis Object Cache" plugin. The configuration follows the [official plugin installation guide](https://github.com/rhubarbgroup/redis-cache/blob/develop/INSTALL.md).

**To enable the cache:**

1. **Install the Redis Object Cache plugin** in WordPress admin:
   - Go to Plugins → Add New
   - Search for "Redis Object Cache" by Till Krüss
   - Install and activate the plugin

2. **Enable the cache**:
   - Go to Settings → Redis
   - The plugin should auto-detect Redis at `redis:6379` (Docker service name)
   - If it doesn't connect automatically, add this to `wp-config.php` (before the `/* That's all, stop editing! Happy publishing. */` line):
     ```php
     define('WP_REDIS_HOST', 'redis');
     define('WP_REDIS_PORT', 6379);
     define('WP_REDIS_PASSWORD', 'redis_password'); // or your REDIS_PASSWORD from .env
     ```
   - Click "Enable Object Cache"

The Redis service runs on an internal network (`cache_net`) and is password-protected for security.

### Volume Backup and Restore

The project includes scripts to backup and restore Podman volumes. This is important for data persistence and disaster recovery.

**Backup volumes:**

```bash
# Make scripts executable (on Linux/VM)
chmod +x backup-volumes.sh restore-volumes.sh

# Create a backup (defaults to ./backups/)
./backup-volumes.sh

# Or specify a custom backup directory
./backup-volumes.sh /path/to/backups

# Stop containers before backup for consistent database backups (recommended)
./backup-volumes.sh --stop-containers
```

**Important:** Backing up while containers are running:
- **Safe for:** `nginx_logs`, `wp_data` (mostly static files)
- **Risky for:** `db_data`, `redis_data` (database files may be inconsistent)

The script will warn you if containers are running. For production backups, it's recommended to:
1. Stop containers before backup: `podman compose stop && ./backup-volumes.sh && podman compose start`
2. Or use the `--stop-containers` flag: `./backup-volumes.sh --stop-containers` (automatically stops and restarts)

The backup script will:
- Create a timestamped backup directory (e.g., `./backups/20240101_120000/`)
- Backup all volumes: `db_data`, `nginx_logs`, `wp_data`, `redis_data`
- Create a manifest file with backup metadata (including whether containers were stopped)

**Restore volumes:**

```bash
# Restore from a specific backup directory
./restore-volumes.sh ./backups/20240101_120000
```

**Copy backups to another machine:**

For disaster recovery, it's recommended to copy backups to an external server:

```bash
# Copy entire backup directory to external server
scp -r ./backups/20240101_120000 user@external-server:/path/to/destination

# Or create a compressed archive first, then copy
tar -czf backup-20240101_120000.tar.gz ./backups/20240101_120000
scp backup-20240101_120000.tar.gz user@external-server:/path/to/destination
```

**Manual backup (single volume):**

If you need to backup a single volume manually, you can use:

```bash
podman run --rm \
  --mount "type=volume,source=<volume-name>,destination=/volume" \
  -v "$(pwd):/backup" \
  busybox \
  tar -czf /backup/<backup-filename>.tar.gz -C /volume .
```

**Note:** Podman Compose prefixes volume names with the project directory name. The scripts automatically detect the correct volume names. To list all volumes manually:

```bash
podman volume ls
```

#### Automatic Startup After Reboot (Systemd Service)

To ensure the containers start automatically after system reboot, set up a systemd user service:

1. **Enable linger for the user (if not already done):**

   ```bash
   sudo loginctl enable-linger bohnenkopf
   ```

2. **Create the systemd user directory:**

   ```bash
   mkdir -p ~/.config/systemd/user
   ```

3. **Create the podman-compose systemd unit template:**

   ```bash
   vi ~/.config/systemd/user/podman-compose@.service
   ```

   Paste the following content (adjust the path to podman-compose if different):

   ```ini
   [Unit]
   Description=%i rootless pod (podman-compose)

   [Service]
   Type=simple
   EnvironmentFile=%h/.config/containers/compose/projects/%i.env
   ExecStartPre=-/home/bohnenkopf/.local/bin/podman-compose up --no-start
   ExecStartPre=/usr/bin/podman pod start pod_%i
   ExecStart=/home/bohnenkopf/.local/bin/podman-compose wait
   ExecStop=/usr/bin/podman pod stop pod_%i

   [Install]
   WantedBy=default.target
   ```

4. **Reload systemd daemon:**

   ```bash
   systemctl --user daemon-reload
   ```

5. **Navigate to your project directory and register the compose file:**

   ```bash
   cd ~/dhbw-cas-laboritsicherheit-runde1
   podman-compose -f docker-compose.yml systemd -a register
   ```

6. **Enable and start the service:**

   ```bash
   systemctl --user enable podman-compose@docker-compose.yml
   systemctl --user start podman-compose@docker-compose.yml
   ```

7. **Verify the service is running:**
   ```bash
   systemctl --user status podman-compose@docker-compose.yml
   podman compose ps
   ```

**Note:** The service name will be based on your project directory name. After registration, you can use:

- `systemctl --user enable --now 'podman-compose@dhbw-cas-laboritsicherheit-runde1'` (if your project dir is `dhbw-cas-laboritsicherheit-runde1`)
- `systemctl --user status 'podman-compose@dhbw-cas-laboritsicherheit-runde1'`
- `journalctl --user -xeu 'podman-compose@dhbw-cas-laboritsicherheit-runde1'`

**Troubleshooting:**

- If `podman-compose` is not found, ensure it's in your PATH. Check with `which podman-compose` and add it to your `~/.bashrc` if needed:
  ```bash
  export PATH="$HOME/.local/bin:$PATH"
  ```
- Verify linger is enabled: `loginctl show-user bohnenkopf | grep Linger`
- Check service logs: `journalctl --user -u podman-compose@docker-compose.yml -f`
- Check pod status: `podman pod ps` and `podman pod stats 'pod_dhbw-cas-laboritsicherheit-runde1'`
