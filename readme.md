# Mein Ansible HomeLab Konfiguration

Dieses Repo enthält die Ansible-Konfiguration meines HomeLabs / Netzwerks. Ziel ist es, Docker-Services, Basis-Systemkonfigurationen und Reverse-Proxy/SSL zentral zu verwalten.

Hosts (Auszug)
- Cloud Server `drogon` bei Hetzner (x86)
- Minisforum MS-01 `rhaegar` (Proxmox Host, nicht mit Ansible verwaltet)
  - VM `tyrion` — Haupt-Docker-Host
  - VM `github_runner_nils`
  - VM `homeassistant`
  - LXC-Container (z.B. Pi-hole)
- 3x ZimaBoards als Proxmox HA Cluster (nicht mit Ansible verwaltet)
- Synology NAS `samwell` (Netzwerkspeicher, nicht mit Ansible verwaltet)

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

## Meine Ansbile Rollen in diesem Repo

Die meisten meiner Ansible Rollen sind Docker Dienste.
Im folgenden findest du eine Liste mit kurzer Beschreibung.
Durchgestrichene Rollen funktioniert zwar, werden aber aktuell nicht von mir verwendet.

- [convertx](https://github.com/C4illin/ConvertX): Mächtiger Datei Converter mit Web-Oberfläche.
- [crafty](https://gitlab.com/crafty-controller/crafty-4): Minecraft Server Manager -> ersetzt einzelne Minecraft Server Rollen aus diesem Repo
- [cyberchef](https://github.com/gchq/CyberChef): Web-Tool mit fokus auf Text Formatierung und Umwandlung.
- docker: Installiert automatisch die richtige Docker Version auf dem Host.
- [docker_socket_proxy](https://github.com/amir20/dozzle): Proxy um einen sicheren Zugriff auf den Docker Socket für andere Container zu ermöglichen.
- [dozzle](https://github.com/amir20/dozzle): Super simpler Browser basierter Docker Container Log-Viewer.
- [ganymede](https://github.com/Zibbp/ganymede): Twitch Livestream Downloader und Archiv
- [grafana](https://github.com/grafana/grafana): Web-Dashboard für alle erdenkklichen Grafiken und Diagramme.
- [homeassistant](https://github.com/home-assistant): Smart Home
- [homebridge](https://github.com/homebridge/homebridge): Tool um nicht unterstützte Smart Home Geräte in Apple Homekit zu integrieren.
- [homepage-dashboard](https://github.com/gethomepage/homepage): Mein Lieblings Homelab Dashboard. Die gesamte Konfiguration passiert in Config-Files.
- [it-tools](https://github.com/CorentinTh/it-tools): Web-Tool mit vielen nützlichen kleinen Werkzeugen für den IT-Alltag.
- [littlelink](https://github.com/techno-tim/littlelink-server): Simple, selbstbetriebene Alternative zu LinkTree
- ~~[lubelogger](https://github.com/hargata/lubelog): Web-Tool zum erfassen von Wartungsarbeiten und anderen Fahrzeug-Daten~~
- ~~minecraft_bedrock: Ein Minecraft Bedrock Edition Server~~
- ~~minecraft_java: Ein Minecraft Java Edition Server~~
- ~~[ntp_server](https://github.com/cturra/docker-ntp): NTP-Server ohne overhead~~
- [openspeedtest](https://github.com/openspeedtest/Docker-Image): Selbstgehosteter Netzwerkgeschwindigkeitstest (leider nicht wirklich Reverse Proxy kompatibel)
- [seerr](https://github.com/seerr-team/seerr): Ermöglicht Nutzern das Anfragen neu gewünschter Filme und Serien für Plex oder Jellyfin
- [pairdrop](https://github.com/schlagmichdoch/PairDrop): AirDrop artiger Datei-Sharing Dienst für alle Betriebssysteme
- [pihole](https://github.com/pi-hole/pi-hole): DNS Blocker, Cache und Server als Docker Container
- plex: Genialer Medien Streaming Dienst ähnlich zu Netflix.
- [prometheus](https://github.com/prometheus/prometheus): Metric-Collector der in meinem Fall für Traefik Metriken verwendet wird.
- ~~promtail_loki: Log-Collector den ich für Traefik nutzen möchte. Aktuell funktioniert das noch nicht wie ich es möchte.~~
- [speedtest-tracker](https://github.com/alexjustesen/speedtest-tracker): Web-Tool das automatisch regelmäsig Internet-Speedtest durchführt und diese in einer Historie dokumentiert.
- [spotify_tracker](https://github.com/Yooooomi/your_spotify): Geniales Statistik Tool für sämtliche Informationen über den eigenen Spotify Musik Konsum.
- [stirling-pdf](https://github.com/Stirling-Tools/Stirling-PDF): Webanwendung mit einer menge nützlicher Werkzeuge zur arbeit mit PDF Dateien.
- teamspeak: Teamspeak 6 Server mit Sprach Video und Text Chat.
- [tautulli](https://github.com/Tautulli/Tautulli): Auswertungs- und Statistik Dashboard für Plex.
- [traefik](https://github.com/traefik/traefik): Dockerbasierter Reverse Proxy mit LetsEncrypt und Docker Socket Integration
- [uptimekuma](https://github.com/louislam/uptime-kuma): Monitoring-Tool / Status-Website
- [vaultwarden](https://github.com/dani-garcia/vaultwarden): Kostenlose Rust Implementierung des Bitwarden Passwort Managers
- [wallos](https://github.com/ellite/wallos): Simpler Abo Tracker mit Web-Interface
- [webserver](https://github.com/nginx/nginx): Simpler nginx Webserver als Docker-Container
- [whats-up-docker](https://github.com/getwud/wud): Docker Image Überwachungstool das z.B. Discord Benachrichtigung sendet wenn neue Images verfügbar sind oder diese auf Wunsch automatisch installiert.
- wordpress: Wordpress Installation als Docker Container

## SSL Zertifikate

Alle benötigen SSL-Zertifikate werden von Traefik Docker Containern erstellt.
Es gibt 2 unterschiedliche Trafik Rollen:
- traefik -> wird für interne Dienste genutzt und generiert Zertifikate per DNS-Challenge
- traefik_httpchallenge -> wird für externe Dienste genutzt und geniert Zertifikate per HTTP-Challenge

## Ansible-Vault / Secrets

Secrets können sicher über den Ansible-Vault abgelegt werden.

Der Ansible Vault kann wie folgt benutzt werden:

- erstellen einer vault-datei: `ansible-vault create traefik.vault.yml`
- bearbeiten einer vault-datei: `ansible-vault edit traefik.vault.yml`
- anschauen einer vault-datei: `ansible-vault view traefik.vault.yml`

Um ein Playbook auszuführen, dass auf den Vault zugreift muss das Passwort zur jeweiligen Vault-ID in einer Umgebungsvarbiable liegen. Dafür habe ich anderer Stelle ein Script.
Alternativ kann  `--ask-vault-pass` an den `ansible-playbook` Befehl angehängt werden und das Passwort manuell eingebene werden.
