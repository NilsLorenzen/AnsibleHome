# Mein Ansible HomeLab Konfiguration

Dieses Repo enthält die Ansible-Konfiguration meines HomeLabs / Netzwerks. Ziel ist es, Docker-Services, Basis-Systemkonfigurationen und Reverse-Proxy/SSL zentral zu verwalten.

Hosts (Auszug)
- Cloud Server `drogon` bei Hetzner (x86) — Playbook `install_drogon.yml`
- Minisforum MS-01 `rhaegar` (Proxmox Host, nicht mit Ansible verwaltet)
  - VM `tyrion` — Haupt-Docker-Host, Playbook `install_tyrion.yml`
  - VM `github_runner_nils`
  - VM `homeassistant`
  - LXC-Container (z.B. Pi-hole, Crafty)
- 3x ZimaBoards als Proxmox HA Cluster (nicht mit Ansible verwaltet)
- Ubiquiti NAS `UNAS-Pro` (Netzwerkspeicher, nicht mit Ansible verwaltet)

`tyrion` und `drogon` sind voneinander unabhängig, kein Dienst wird über den jeweils anderen Host veröffentlicht.
`arya` steht zusätzlich im Inventory, hat aber kein eigenes Playbook.

Voraussetzungen
- Mac: Homebrew, dann:
  - `brew install ansible`
- Ubuntu / WSL:
  - `sudo apt update`
  - `sudo apt install software-properties-common`
  - `sudo add-apt-repository --yes --update ppa:ansible/ansible`
  - `sudo apt install ansible`

Die Playbooks können Ansible Librarys benötigen. Diese werden in der `requirements.yml` gesammelt.
Mit folgendem Befehl können alle auf einmal installiert werden:

`sh bootstrap`

## Playbooks ausführen

Jede Rolle hat im Playbook einen Tag, damit lässt sich ein einzelner Dienst ausrollen:

- Trockenlauf mit Diff: `ansible-playbook install_tyrion.yml --check --diff --tags plex`
- Echter Lauf: `ansible-playbook install_tyrion.yml --tags plex`
- System-Rollen (`system_config`, `admin_users`, `ssh_hardening`) hängen am Tag `system`.

## Meine Ansible Rollen in diesem Repo

Die meisten meiner Ansible Rollen sind Docker Dienste.
Im folgenden findest du eine Liste mit kurzer Beschreibung. Sie wird automatisch erzeugt, Texte und Links stehen in [docs/roles.yml](docs/roles.yml).
Durchgestrichene Rollen funktionieren zwar, werden aber aktuell nicht von mir verwendet — die Gründe stehen unter [Ruhende Rollen](#ruhende-rollen).

<!-- BEGIN ROLLENLISTE: automatisch erzeugt von scripts/update_readme.py, Texte in docs/roles.yml -->

### System-Rollen

- admin_users: Legt die Admin-User samt Gruppen an, richtet passwortloses sudo ein und holt die SSH-Keys von GitHub. (beide)
- docker: Installiert automatisch die richtige Docker Version auf dem Host. (beide)
- ssh_hardening: Gehärtete `sshd_config`. Einzige Quelle für `AllowUsers` ist `sshd_allow_users` im Playbook. (beide)
- system_config: Zeitzone, Locale, Basis-Pakete und automatische Sicherheitsupdates. (beide)

### Dienste

- [cobaltdownloader](https://github.com/imputnet/cobalt): Downloader für Videos und Audio von Social-Media-Seiten, API und selbst gehostetes Web-Frontend. (tyrion)
- [convertx](https://github.com/C4illin/ConvertX): Mächtiger Datei Converter mit Web-Oberfläche. (tyrion)
- ~~[crafty](https://gitlab.com/crafty-controller/crafty-4): Minecraft Server Manager~~
- [crowdsec](https://github.com/crowdsecurity/crowdsec): Erkennung und Blockieren von Angriffen, mit WAF (AppSec), Web-Konsole und Discord-Benachrichtigung. (drogon)
- [cyberchef](https://github.com/gchq/CyberChef): Web-Tool mit fokus auf Text Formatierung und Umwandlung. (tyrion)
- [docker_socket_proxy](https://github.com/linuxserver/docker-socket-proxy): Proxy um einen sicheren Zugriff auf den Docker Socket für andere Container zu ermöglichen. (beide)
- [docmost](https://github.com/docmost/docmost): Wiki für Dokumentation und Notizen. (tyrion)
- [dozzle](https://github.com/amir20/dozzle): Super simpler Browser basierter Docker Container Log-Viewer. (beide)
- [excalidraw](https://github.com/excalidraw/excalidraw): Virtuelles Whiteboard für Skizzen und Diagramme. (tyrion)
- [ganymede](https://github.com/Zibbp/ganymede): Twitch Livestream Downloader und Archiv (tyrion)
- ~~[grafana](https://github.com/grafana/grafana): Web-Dashboard für alle erdenklichen Grafiken und Diagramme.~~
- ~~[homeassistant](https://github.com/home-assistant): Smart Home~~
- ~~[homebridge](https://github.com/homebridge/homebridge): Tool um nicht unterstützte Smart Home Geräte in Apple Homekit zu integrieren.~~
- [homepage](https://github.com/gethomepage/homepage): Mein Lieblings Homelab Dashboard. Die gesamte Konfiguration passiert in Config-Files. (tyrion)
- [it-tools](https://github.com/CorentinTh/it-tools): Web-Tool mit vielen nützlichen kleinen Werkzeugen für den IT-Alltag. (tyrion)
- ~~[littlelink](https://github.com/techno-tim/littlelink-server): Simple, selbstbetriebene Alternative zu LinkTree~~
- ~~minecraft_bedrock: Ein Minecraft Bedrock Edition Server~~
- ~~minecraft_java: Ein Minecraft Java Edition Server~~
- [networking-toolbox](https://github.com/Lissy93/networking-toolbox): Sammlung von Netzwerk-Werkzeugen im Browser. (tyrion)
- [nilslorenzende](https://github.com/NilsLorenzen/nilslorenzende): Meine persönliche Website unter nilslorenzen.de, als privates Image aus GHCR. (drogon)
- ~~[ntp_server](https://github.com/cturra/docker-ntp): NTP-Server ohne overhead~~
- [openspeedtest](https://github.com/openspeedtest/Docker-Image): Selbstgehosteter Netzwerkgeschwindigkeitstest (leider nicht wirklich Reverse Proxy kompatibel) (tyrion)
- [pairdrop](https://github.com/schlagmichdoch/PairDrop): AirDrop artiger Datei-Sharing Dienst für alle Betriebssysteme (tyrion)
- [paperlessngx](https://github.com/paperless-ngx/paperless-ngx): Dokumentenverwaltung mit Texterkennung (OCR). (tyrion)
- ~~[pihole](https://github.com/pi-hole/pi-hole): DNS Blocker, Cache und Server als Docker Container~~
- plex: Genialer Medien Streaming Dienst ähnlich zu Netflix. (tyrion)
- ~~[prometheus](https://github.com/prometheus/prometheus): Metric-Collector der in meinem Fall für Traefik Metriken verwendet wird.~~
- [scribblers](https://github.com/scribble-rs/scribble.rs): Multiplayer Zeichen- und Ratespiel im Browser. (tyrion)
- [seerr](https://github.com/seerr-team/seerr): Ermöglicht Nutzern das Anfragen neu gewünschter Filme und Serien für Plex oder Jellyfin (tyrion)
- [speedtest-tracker](https://github.com/alexjustesen/speedtest-tracker): Web-Tool das automatisch regelmäsig Internet-Speedtest durchführt und diese in einer Historie dokumentiert. (tyrion)
- [spielekiste](https://github.com/NilsLorenzen/spielekiste): Meine Web-App mit Minispielen, solo und online mit Lobbys, als privates Image aus GHCR. (drogon)
- [spotify_tracker](https://github.com/Yooooomi/your_spotify): Geniales Statistik Tool für sämtliche Informationen über den eigenen Spotify Musik Konsum. (tyrion)
- spotizerr: Musik-Downloader mit Web-Oberfläche. (tyrion)
- [stirling-pdf](https://github.com/Stirling-Tools/Stirling-PDF): Webanwendung mit einer menge nützlicher Werkzeuge zur arbeit mit PDF Dateien. (tyrion)
- [tautulli](https://github.com/Tautulli/Tautulli): Auswertungs- und Statistik Dashboard für Plex. (tyrion)
- teamspeak: Teamspeak 6 Server mit Sprach Video und Text Chat. (drogon)
- [traefik](https://github.com/traefik/traefik): Dockerbasierter Reverse Proxy mit LetsEncrypt und Docker Socket Integration (beide)
- [uptimekuma](https://github.com/louislam/uptime-kuma): Monitoring-Tool / Status-Website (drogon)
- [vaultwarden](https://github.com/dani-garcia/vaultwarden): Kostenlose Rust Implementierung des Bitwarden Passwort Managers (tyrion)
- [wallos](https://github.com/ellite/wallos): Simpler Abo Tracker mit Web-Interface (tyrion)
- [webserver](https://github.com/nginx/nginx): Simpler nginx Webserver als Docker-Container (drogon)
- [whats-up-docker](https://github.com/getwud/wud): Docker Image Überwachungstool das z.B. Discord Benachrichtigung sendet wenn neue Images verfügbar sind oder diese auf Wunsch automatisch installiert. (beide)
- [wordpress_mfw](https://github.com/WordPress/WordPress): Wordpress Installation mit MariaDB als Docker Container (drogon)

<!-- END ROLLENLISTE -->

### Ruhende Rollen

Diese Rollen bleiben im Repo, werden aber aktuell nicht ausgerollt:

| Rolle | Grund |
|---|---|
| crafty | Läuft inzwischen als LXC-Container auf Proxmox. |
| crowdsec (nur tyrion) | IDS/IPS und Geoblocking übernimmt der Ubiquiti-Router. Auf drogon läuft crowdsec (siehe [CrowdSec und WAF](#crowdsec-und-waf-drogon)). |
| grafana, prometheus | Werden nicht gebraucht. Im Playbook auskommentiert, offene Punkte siehe unten. |
| homeassistant | Läuft als eigene VM auf Proxmox, von außen über Traefik auf tyrion (siehe [Home Assistant von außen](#home-assistant-von-außen-mtls)). |
| homebridge | Wird aktuell nicht genutzt. |
| littlelink | Ersetzt durch die eigene Website `nilslorenzende`, me.nilslorenzen.de leitet dorthin um. |
| minecraft_java, minecraft_bedrock | Werden aktuell nicht genutzt. |
| ntp_server | Wird aktuell nicht genutzt. |
| pihole | Läuft als LXC-Container auf Proxmox. |

**Offene Punkte bei einer Reaktivierung von Grafana und Prometheus:**
- Der Prometheus-Job `traefik:8080` läuft ins Leere, Traefik definiert keinen Metrics-Entrypoint.
- Der Job `192.168.10.16:9100` hat keinen node_exporter als Gegenstelle.
- `roles/grafana/dashboards/traefik-dashboard.json` wird von keinem Task ausgerollt und nutzt Loki als Datenquelle, das es nicht mehr gibt.
- Grafana hat kein gesetztes Admin-Passwort.

## Aufbau einer Rolle

Fast alle Dienst-Rollen folgen demselben Muster: eine systemd-Unit startet `docker compose up` im Verzeichnis `/data/<rolle>`, beides kommt aus Jinja-Templates, Änderungen lösen über einen Handler einen Restart aus.

Der Ablauf steht einmal zentral in `tasks/docker-compose-service.yml`, eine Rolle braucht nur:
- in `tasks/main.yml` den Aufruf `ansible.builtin.import_tasks: docker-compose-service.yml` (zusätzliche Tasks, die vor dem Start fertig sein müssen, stehen davor),
- in `handlers/main.yml` den Handler `restart {{ role_name }}.service` mit `daemon_reload: true`,
- in `templates/` die `docker-compose.yml.j2` (und was sonst nach `/data/<rolle>` gehört).

Das Datenverzeichnis ist immer `/data/<rolle>`: `root` steht einmal in `group_vars/all/services.yml` als `/data/{{ role_name }}`, nicht in den Rollen.

Die systemd-Unit ist für alle Dienste dieselbe: `templates/docker-compose.service.j2` im Repo-Root. Abweichungen gibt die Rolle als `vars:` am `import_tasks` mit — `service_description`, `service_requires_mounts_for` (plex, ganymede), `service_restart` (pihole). **Nicht** in `defaults/main.yml`: Rollen-Defaults gelten für alle Rollen im selben Play. Eine Rolle mit eigenem `templates/<rolle>.service.j2` behält ihre eigene Unit.

Geänderte Dateien lösen den Restart sofort per `flush_handlers` aus, noch bevor der Service gestartet wird. Das arbeitet auch anstehende Handler früherer Rollen im selben Lauf ab.

Kopiert werden die Templates über `tasks/copy-all-templates.yml`:
- Der ganze `templates/`-Ordner wird nach `/data/<rolle>` gespiegelt, `.j2` wird gerendert.
- Dateien mit dem Prefix `nr_` lösen keinen Restart aus (das Prefix wird beim Kopieren entfernt).
- `*.service.j2` landet in `/etc/systemd/system`, `*-logrotate.j2` in `/etc/logrotate.d`.
- `file_mode` setzt den Modus der Dateien in `/data/<rolle>` (Default `644`). Traefik, Vaultwarden, Homepage und Crowdsec nutzen `640`, weil in ihren Dateien Zugangsdaten mit Wirkung über den eigenen Dienst hinaus stehen; die Spielekiste wegen des Admin-Passwort-Hashes.
- `copy_exclude` nimmt Templates aus, die die Rolle selbst an einen anderen Ort schreibt (z.B. Mount-Units bei plex und ganymede).

## SSL Zertifikate

Alle benötigen SSL-Zertifikate werden von Traefik Docker Containern erstellt.
Beide Hosts nutzen dieselbe Rolle `traefik`, die Unterschiede stehen in `host_vars/<host>/traefik.yml`:
- `traefik_challenge`: `dns` auf tyrion (INWX, erlaubt Wildcard-Zertifikate), `http` auf drogon
- `traefik_dashboard_middleware`: Middleware vor dem Traefik-Dashboard
- `traefik_lan_only_sourcerange`: nur wenn gesetzt, wird die Middleware `lan-only` definiert (tyrion)
- `traefik_dynamic_configs`: welche Dateien aus `roles/traefik/templates/conf/dynamic/` auf dem Host landen. Alle anderen werden nicht ausgerollt — wichtig, weil z.B. `linkshortener.yml` Router ohne Host-Regel enthält, die auf jeder Domain greifen würden. Jede andere Datei in `/data/traefik/conf/dynamic/` (auch längst aus dem Repo gelöschte) entfernt die Rolle vom Host; Traefik übernimmt das ohne Neustart.

Traefik auf `tyrion` ist über Port-Forwarding 80/443 direkt aus dem Internet erreichbar. Die Zugriffsgrenze ist deshalb die Middleware am jeweiligen Router:
- `lan-only`: nur aus den eigenen Netzen erreichbar.
- `basic-auth-nils-only` / `basic-auth-all`: Basic-Auth vor dem Dienst.
- Ohne Middleware sind nur Dienste mit eigener Anmeldung, die bewusst von außen erreichbar sein sollen (aktuell `plex`, `seerr`, `vaultwarden`).
- Ebenfalls ohne Middleware: Router mit `tls.options: mtls`. Dort lässt Traefik nur Geräte mit Client-Zertifikat durch (aktuell Home Assistant, siehe unten).

Ein Router ohne `middlewares=`-Label ist also öffentlich.

### Home Assistant von außen (mTLS)

Home Assistant läuft als eigene VM (`homeassistant.home-lorenzen.de:8123`, eigenes Let's-Encrypt-Zertifikat) und ist von außen unter `ha.nlor.de` erreichbar. Traefik auf tyrion leitet dorthin weiter, aber nur für Geräte mit einem Client-Zertifikat der eigenen CA. Ohne Zertifikat bricht schon der TLS-Handshake ab, Home Assistant sieht davon nichts.

- Konfiguration: `roles/traefik/templates/conf/dynamic/homeassistant.yml.j2`, Werte in `host_vars/tyrion/traefik.yml` (`traefik_homeassistant_*`, `traefik_mtls_ca_cert`).
- DNS: `ha.nlor.de` ist bei INWX ein CNAME auf `home.nlor.de`. `home-lorenzen.de` bleibt öffentlich leer.
- Home Assistant (`configuration.yaml`): `http:` mit `use_x_forwarded_for: true` und `trusted_proxies: [192.168.10.16]`, sonst antwortet es über Traefik mit 400.
- Companion App (iPhone, Watch, Mac): interne URL `https://homeassistant.home-lorenzen.de:8123` im Heim-WLAN, externe URL `https://ha.nlor.de`. mTLS ist dort ein Labs-Feature (Einstellungen → Companion App → Debugging → Labs), die `.p12` wird in den Server-Einstellungen der App importiert. Die Watch übernimmt das Zertifikat vom iPhone.
- Browser auf dem Mac: `.p12` per Schlüsselbundverwaltung in den Anmelde-Schlüsselbund, nicht als `.mobileconfig`.

Zertifikate stellt `scripts/mtls_ca.sh` lokal aus (ECDSA P-256, ein Zertifikat pro Gerät, 2 Jahre gültig):

- `scripts/mtls_ca.sh <verzeichnis> ca` – CA einmalig anlegen, `ca.crt` kommt als `traefik_mtls_ca_cert` in die host_vars.
- `scripts/mtls_ca.sh <verzeichnis> client <name>` – Zertifikat samt `.p12` für ein Gerät.
- Das Verzeichnis muss außerhalb des Repos liegen. CA-Schlüssel, `.p12` und die Passwörter liegen in Vaultwarden.
- Die `.p12` ist mit 3DES/SHA1 verschlüsselt, weil der macOS-Schlüsselbund das AES-Format von OpenSSL 3 ablehnt. Deshalb lange Passwörter nehmen.

Traefik prüft keine Sperrlisten. Geht ein Gerät verloren: neue CA anlegen, `traefik_mtls_ca_cert` ersetzen, traefik ausrollen und alle Geräte neu ausstatten.

## CrowdSec und WAF (drogon)

drogon steht nicht hinter dem Ubiquiti-Router und hat damit weder IDS/IPS noch Geoblocking. Die Schutzschicht dort ist CrowdSec mit AppSec als WAF, angebunden über das Traefik-Plugin [crowdsec-bouncer-traefik-plugin](https://github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin).

- Der Container `crowdsec` (Rolle `crowdsec`) liest das Access-Log von Traefik, sperrt auffällige IPs und prüft als WAF jede Anfrage (Regeln `appsec-virtual-patching` und `appsec-generic-rules`, kein OWASP-CRS).
- Traefik fragt beides über die Middleware `crowdsec@file` ab (`roles/traefik/templates/conf/dynamic/crowdsec.yml.j2`). Sie hängt am Entrypoint `https`, gilt also für jeden Router, auch künftige, und läuft vor Basic-Auth.
- Eingeschaltet wird das allein über `crowdsec.yml` in `traefik_dynamic_configs`. Dann lädt `traefik.yml` auch das Plugin.
- Fällt crowdsec aus, lässt Traefik Anfragen ungeprüft durch. Die Units haben kein `Restart=`, sonst stünden alle Seiten still.
- Die Plugin-Version ist in `roles/traefik/templates/conf/traefik.yml.j2` gepinnt. Traefik lädt das Plugin bei jedem Start von plugins.traefik.io. Klappt das nicht, liefern alle Router auf drogon Fehler: dann `crowdsec.yml` aus `traefik_dynamic_configs` nehmen und traefik ausrollen.
- Web-Konsole: Die Instanz meldet sich per Enroll-Key bei [app.crowdsec.net](https://app.crowdsec.net) an und wird dort einmalig bestätigt. Sperren meldet crowdsec zusätzlich in Discord.
- Vault (`host_vars/drogon/crowdsec.vault.yml`): `vault_crowdsec_discord_webhook`, `vault_crowdsec_enroll_key`, `vault_crowdsec_bouncer_key_traefik`. Den Bouncer-Key nutzen beide Rollen: crowdsec registriert ihn, Traefik meldet sich damit an.

Befehle auf drogon (`docker exec crowdsec …`):
- `cscli metrics`, `cscli metrics show appsec`: was gelesen und geprüft wird
- `cscli alerts list`, `cscli decisions list`: Erkennungen und aktive Sperren
- `cscli decisions delete --ip <ip>`: ausgesperrte IP freigeben
- `cscli bouncers list`, `cscli console status`: Anbindung von Traefik und Konsole

Schnelltest von außen: `curl -i https://nilslorenzen.de/.env` muss mit 403 enden.

## Ansible-Vault / Secrets

Secrets können sicher über den Ansible-Vault abgelegt werden.

Der Ansible Vault kann wie folgt benutzt werden:

- erstellen einer vault-datei: `ansible-vault create traefik.vault.yml`
- bearbeiten einer vault-datei: `ansible-vault edit traefik.vault.yml`
- anschauen einer vault-datei: `ansible-vault view traefik.vault.yml`

Um ein Playbook auszuführen, dass auf den Vault zugreift muss das Passwort zur jeweiligen Vault-ID in einer Umgebungsvarbiable liegen. Dafür habe ich anderer Stelle ein Script.
Alternativ kann  `--ask-vault-pass` an den `ansible-playbook` Befehl angehängt werden und das Passwort manuell eingebene werden.

Konventionen:
- Alle `*.vault.yml` sind mit der Vault-ID `nlo` verschlüsselt. Das Label wird im Repo nicht aufgelöst (kein Eintrag in `ansible.cfg`), das Passwort kommt aus dem externen Script.
- Vault-Variablen heißen `vault_<rolle oder thema>_<name>` und werden in der unverschlüsselten Datei daneben auf den eigentlichen Variablennamen gemappt (z.B. `docmost_db_password: "{{ vault_docmost_db_password }}"`).
- bcrypt-Hashes für Basic-Auth liegen im Vault mit **einfachem** `$`, genau wie `htpasswd -nbB -C 12 user 'pw' | cut -d: -f2` sie ausgibt. Die Traefik-Compose-Templates verdoppeln selbst auf `$$`.
- Bei Traefik hängen zwei Werte zusammen: `vault_traefik_nils_hash` (Basic-Auth) und `vault_traefik_nils_password` (Klartext für die Homepage-Widgets). Bei einer Rotation beide ändern.

## Lokale Prüfung

Alle Prüfungen laufen per [pre-commit](https://pre-commit.com) bei jedem Commit: einmalig `pre-commit install`, manuell `pre-commit run --all-files`. Dabei wird auch die Rollenliste oben aus `docs/roles.yml` und den Playbooks neu erzeugt – neue Rollen brauchen dort einen Eintrag.

- `ansible-playbook --syntax-check install_tyrion.yml install_drogon.yml` (braucht kein Vault-Passwort)
- `ansible-lint` (Konfiguration in `.ansible-lint`; Regeln in der `warn_list` sind bekannte Altlasten)
- `yamllint .` (Konfiguration in `.yamllint`; `yamllint` wird mit `ansible-lint` mitinstalliert)

## Bekannte Lücken

Bewusst nicht in diesem Repo, damit es nicht wie ein Versehen aussieht:
- **Backups** werden außerhalb dieses Repos geregelt.
- **ufw** wird von `system_config` installiert, aber nicht konfiguriert.
- **Fehlermails der Units**: alle systemd-Units verweisen auf `OnFailure=unit-status-mail@%n.service`, diese Unit wird aber nirgends angelegt. Fällt ein Dienst aus, kommt also keine Mail.
- **Crowdsec auf tyrion**: aus, weil der Ubiquiti-Router IDS/IPS und Geoblocking übernimmt. Geplant ist, die Middleware nur an die öffentlichen Router `plex`, `seerr` und `vaultwarden` zu hängen, nicht an den Entrypoint. Bis dahin stehen in diesen Rollen und im Compose-Template von Traefik noch auskommentierte `crowdsec`-Zeilen aus der alten Einrichtung.
- **Kein Restart bei Absturz**: die Units starten `docker compose up --abort-on-container-exit` ohne `Restart=` (einzige Ausnahme: `pihole`). Stirbt ein Container, bleibt der ganze Stack unten, bis man eingreift.
