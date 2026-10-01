# AnsibleHome

Ansible für zwei unabhängige Docker-Hosts: `tyrion` (Proxmox-VM im Heimnetz, `install_tyrion.yml`)
und `drogon` (Hetzner Cloud, `install_drogon.yml`). Kein Dienst wird über den anderen Host veröffentlicht.
Rollen, ruhende Rollen und bekannte Lücken: readme.md. Die Rollenliste darin wird aus `docs/roles.yml`
und den Playbooks erzeugt (`scripts/update_readme.py`, läuft per pre-commit) – nicht von Hand ändern.

## Arbeitsweise

- Eine Aufgabe pro Schritt, danach Ergebnis, Prüfung und Commit-Message-Vorschlag zeigen und fragen.
- Nie committen, pushen oder stagen – Nils committet selbst.
- Vault-Inhalte nie anfassen: `ansible-vault edit` macht Nils. Stattdessen die nötigen Vault-Variablen auflisten.
- Bei Entscheidungen fragen statt annehmen. Auf den Hosts nichts ausführen, sondern Dry-Run-Befehle liefern
  und vorher sagen, welche Dienste auf welchem Host neu starten.

## Aufbau einer Dienst-Rolle

Neue Rolle: Skill `new-service-role`.

- `tasks/main.yml`: `ansible.builtin.import_tasks: docker-compose-service.yml`. Tasks, die vor dem Start
  fertig sein müssen (NAS-Mount, Git-Checkout, Docker-Netz), stehen davor.
- `handlers/main.yml`: `restart {{ role_name }}.service` mit `daemon_reload: true`, ohne `when`.
- `templates/docker-compose.yml.j2` plus alles, was nach `/data/<rolle>` gehört. Keine eigene Unit:
  alle Dienste nutzen `templates/docker-compose.service.j2` im Repo-Root.
- Rollen-Parameter (`file_mode`, `copy_exclude`, `service_description`, `service_requires_mounts_for`,
  `service_restart`) als `vars:` am `import_tasks` – **nie in `defaults/main.yml`**: Rollen-Defaults gelten
  für alle Rollen im Play, und alle Rollen eines Hosts laufen in einem Play.
- `root` ist `/data/{{ role_name }}` und steht nur in `group_vars/all/services.yml`.
- `file_mode` Default `644`; `640` bei traefik, vaultwarden, homepage (Zugangsdaten mit Außenwirkung).
- `nr_`-Prefix in `templates/`: Datei wird ohne Restart kopiert (Prefix fällt weg).
  `copy_exclude`: Templates, die die Rolle selbst woanders hinschreibt (Mount-Units mit NAS-Passwort,
  Dateien unter `/etc`) – sonst landen sie zusätzlich in `/data`.
- Handler laufen per `flush_handlers` vor dem Start-Task – dabei auch anstehende Handler früherer Rollen.
- Variablen der Rolle heißen `<rolle>_…` (z.B. `<rolle>_domain`), neue Rollennamen ohne Bindestrich.

## Sicherheit

- Traefik auf tyrion hängt per Port-Forwarding direkt am Internet. Die Zugriffsgrenze ist die Middleware:
  jeder Router braucht `lan-only`, `basic-auth-nils-only` oder `basic-auth-all`. Ohne Middleware nur
  plex, seerr, vaultwarden (eigene Anmeldung, bewusst öffentlich). Ein fehlendes `middlewares=` ist ein Leck.
- Übliches Muster: Router `-lan` (`HeaderRegexp` auf private IPs + `lan-only`) und Router `-app`
  (gleicher Host + `basic-auth-*`) – im LAN ohne Passwort, von außen mit.
- `lan-only` gibt es nur auf tyrion. drogon hat keinen Router-Schutz (kein IDS/IPS, kein Geoblocking).
- Secrets nur über den Vault: `vault_<rolle>_<name>` in `*.vault.yml` (Vault-ID `nlo`), in der
  Datei daneben auf den Rollennamen gemappt, im Template mit `| mandatory`.
- bcrypt-Hashes liegen im Vault mit einfachem `$`; die Traefik-Templates verdoppeln selbst.
- Traefik-Dynamic-Configs nur über `traefik_dynamic_configs` pro Host: `linkshortener.yml` enthält
  Router ohne Host-Regel und darf nie auf tyrion landen.

## Prüfen (lokal, ohne Host)

- `pre-commit run --all-files` bündelt readme-Rollenliste, Syntax-Check, yamllint und ansible-lint.
- `ansible-playbook --syntax-check install_tyrion.yml install_drogon.yml < /dev/null`
- `~/.local/bin/ansible-lint` muss mit Exit 0 enden; ein Treffer ohne „(warning)" ist eine Regression.
- `~/.local/pipx/venvs/ansible-lint/bin/yamllint .`
- Änderungen an Rollen, Templates oder `tasks/`: alt gegen neu vergleichen mit Skill `compare-render`.
- Nils prüft auf dem Host mit `ansible-playbook install_<host>.yml --check --diff --tags <tag>`.

## Fallen

- Ad-hoc-Befehle aus dem Repo scheitern an „no vault secrets" (group_vars werden geladen) –
  aus einem anderen Verzeichnis mit `-i localhost, -c local` arbeiten.
- Templates mit `{%` oder `{#` rendern mit `lstrip_blocks` anders als ohne – vor Umstellungen prüfen.
- macOS `sed -i` wendet die umask an (664 → 644): Dateimodi vorher erfassen.
- `~/.ansible/collections` kann veraltete Collections enthalten, die neuere verdecken: `sh bootstrap --force`.
- Alles ist LF (`.gitattributes`); Python `open()` im Textmodus normalisiert CRLF still.
- zsh teilt `$VAR` nicht an Leerzeichen und expandiert `local a=$1 b=$a` vor der Zuweisung.
