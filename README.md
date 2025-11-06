# DHBW CAS - Labor IT Sicherheit - Runde 1

Gruppenmitglieder:

- Jens Hausdorf
- Tobias Goetz

## Aufgabenstellung

Setzen Sie in der VM einen Server unter Verwendung geeigneter Werkzeuge und Technologien auf. Wählen Sie im Zweifelsfall die einfachere Realisierungsvariante, damit Sie nicht mit „Kanonen auf Spatzen schießen“. Die Webseite braucht neben der Grundfunktionalität für den beschriebenen Anwendungsfall keine echten oder gar sinnvolle Inhalte und ein ausgefeiltes Design zu haben, aber etwas Content in einigermaßen ansprechender Form (gerne KI-generiert) wäre nett, um einen realistischen Eindruck zu haben.

Überlegen Sie sich, wie das System (auf den verschiedenen Ebenen OS, Webserver, Anwendung) dem Schutzbedarf entsprechend abgesichert werden kann. Dokumentieren Sie, wie Sie zu Ihren Entscheidungen gelangt sind und (kurz, aber nachvollziehbar) wie Sie diese umgesetzt haben. Halten Sie fest, gegen welche

Bedrohungen Ihre Maßnahmen wirken. Ggf. können Sie auch noch angeben, wie die Wirksamkeit der Maßnahmen überprüft werden kann.

Bauen Sie zu Demonstrationszwecken bitte absichtlich am zwei Schwachstellen in Ihre Lösung ein. Diese Schwachstellen dokumentieren Sie in einem separaten Dokument kurz (Ursache, praktische Ausnutzung, mögliche Konsequenzen). Beschreiben Sie, wie die Schwachstellen vermieden werden können. Dies kann auch in der Form geschehen, dass Sie in bestimmten Teilen Ihres Systems Realisierungsvarianten ohne diese Schwachstellen umsetzen.

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

For deployment on the production VM (alma1.schach.kids):

1. Establish SSH connection to the VM:

   ```bash
   ssh bohnenkopf@alma1.schach.kids
   ```

2. Clone or update the repository:

   ```bash
   git clone git@github.com:TobiasGoetz/dhbw-cas-laboritsicherheit-runde1.git
   cd dhbw-cas-laboritsicherheit-runde1
   # or if already present:
   git pull
   ```

3. Create `.env` file with production passwords:

   ```bash
   # Create a .env file with secure passwords
   WP_DB_PASSWORD=<secure_password>
   MYSQL_ROOT_PASSWORD=<secure_root_password>
   ```

4. Set up SSL certificates with Certbot (for initial setup):

   ```bash
   podman compose run --rm certbot certonly --webroot \
     --webroot-path=/var/www/certbot \
     --email admin@alma1.schach.kids \
     --agree-tos \
     --no-eff-email \
     -d alma1.schach.kids \
     -d www.alma1.schach.kids
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

The application is accessible at `https://alma1.schach.kids`. The production configuration uses SSL/TLS with Let's Encrypt certificates and redirects all HTTP requests to HTTPS.

**Important:** Make sure the firewall on the VM allows incoming connections on ports 80 and 443.

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
