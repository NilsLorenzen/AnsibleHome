---
name: new-service-role
description: Legt eine neue Docker-Dienst-Rolle in AnsibleHome nach der Repo-Konvention an – Rolle, Compose-Template mit Traefik-Labels und passender Middleware, host_vars, Playbook-Eintrag mit Tag, readme – und liefert die nötigen Vault-Variablen und Dry-Run-Befehle. Verwenden, wenn Nils einen neuen Dienst (Container/Image) auf tyrion oder drogon hosten will.
---

# new-service-role

Eine neue Rolle besteht aus drei Dateien plus Einträgen in host_vars, Playbook und readme.
Ablauf und Verteilung der Unit übernimmt `tasks/docker-compose-service.yml` – nichts davon kopieren.

## 1. Vorher klären (fragen, nicht annehmen)

| Frage | Hinweise |
|---|---|
| Rollenname | klein, **ohne Bindestrich** (`_` erlaubt). Er wird zu Unit-Name, `COMPOSE_PROJECT_NAME` und `/data/<rolle>` – später nicht mehr änderbar, ohne den Host anzufassen. |
| Host | `tyrion` (Heimnetz, DNS-Challenge, Wildcard-Zertifikate) oder `drogon` (Hetzner, HTTP-Challenge: DNS-A-Record muss vorher auf drogon zeigen). |
| Image und Port | Image-Tag wie im Rest des Repos (`:latest` ist bewusst erlaubt), interner Port für den Traefik-Service. |
| Domain | `<name>.home-lorenzen.de` oder `<name>.nlor.de`. |
| Zugriff | siehe Abschnitt 3. **Öffentlich ohne Middleware nur nach ausdrücklicher Bestätigung.** |
| Secrets | Welche Env-Variablen sind geheim? Sie kommen in den Vault. |
| Volumes | Unterverzeichnisse von `{{ root }}` (= `/data/<rolle>`), nie absolute Pfade außerhalb ohne Grund. |
| Zusatzdateien | Configs für `/data/<rolle>` als Templates; Dateien für andere Orte → eigener Task + `copy_exclude`. |
| Dateimodus | `file_mode: '640'`, wenn Zugangsdaten mit Außenwirkung in den Dateien stehen (fremde Konten, geteilte Passwörter); sonst Default 644. |
| Homepage | Soll der Dienst auf dem Dashboard erscheinen? (`roles/homepage/templates/config/nr_services.yaml.j2`) |

## 2. Dateien anlegen

`roles/<rolle>/tasks/main.yml`
```yaml
- name: Deploy {{ role_name }}
  ansible.builtin.import_tasks: docker-compose-service.yml
```
Parameter wie `file_mode`, `copy_exclude`, `service_description` als `vars:` an **diesen** Task –
nie in `defaults/main.yml` (Rollen-Defaults gelten für alle Rollen im Play). Kein `root` definieren.

`roles/<rolle>/handlers/main.yml`
```yaml
- name: restart {{ role_name }}.service
  ansible.builtin.systemd:
    name: "{{ role_name }}.service"
    state: restarted
    daemon_reload: true
```

`roles/<rolle>/templates/docker-compose.yml.j2` – Grundgerüst:
```yaml
networks:
  web:
    external: true

services:
  app:
    image: <image>:latest
    container_name: {{ role_name }}
    networks:
      - web
    environment:
      - EXAMPLE_SECRET={{ <rolle>_example_secret | mandatory }}
    volumes:
      - {{ root }}/data:/data
    labels:
      - traefik.enable=true
      - traefik.http.services.${COMPOSE_PROJECT_NAME}-service.loadbalancer.server.port=<port>

      # Router-Block aus Abschnitt 3

      - wud.watch.digest=true
```

`host_vars/<host>/<rolle>.yml`
```yaml
<rolle>_domain: <name>.home-lorenzen.de
<rolle>_example_secret: "{{ vault_<rolle>_example_secret }}"
```

## 3. Zugriff: Router-Labels

Traefik auf tyrion hängt direkt am Internet – jeder Router braucht eine Middleware.

**Nur im LAN** (nur tyrion):
```yaml
      - traefik.http.routers.${COMPOSE_PROJECT_NAME}-lan.rule=Host(`{{ <rolle>_domain | mandatory }}`)
      - traefik.http.routers.${COMPOSE_PROJECT_NAME}-lan.service=${COMPOSE_PROJECT_NAME}-service
      - traefik.http.routers.${COMPOSE_PROJECT_NAME}-lan.entrypoints=https
      - traefik.http.routers.${COMPOSE_PROJECT_NAME}-lan.middlewares=lan-only
```

**Im LAN ohne Passwort, von außen mit Basic-Auth** (häufigstes Muster auf tyrion):
```yaml
      - traefik.http.routers.${COMPOSE_PROJECT_NAME}-lan.rule=Host(`{{ <rolle>_domain | mandatory }}`) && HeaderRegexp(`X-Real-Ip`, `(^127\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)`)
      - traefik.http.routers.${COMPOSE_PROJECT_NAME}-lan.service=${COMPOSE_PROJECT_NAME}-service
      - traefik.http.routers.${COMPOSE_PROJECT_NAME}-lan.entrypoints=https
      - traefik.http.routers.${COMPOSE_PROJECT_NAME}-lan.middlewares=lan-only

      - traefik.http.routers.${COMPOSE_PROJECT_NAME}-app.rule=Host(`{{ <rolle>_domain | mandatory }}`)
      - traefik.http.routers.${COMPOSE_PROJECT_NAME}-app.service=${COMPOSE_PROJECT_NAME}-service
      - traefik.http.routers.${COMPOSE_PROJECT_NAME}-app.entrypoints=https
      - traefik.http.routers.${COMPOSE_PROJECT_NAME}-app.middlewares=basic-auth-all
```
Der `HeaderRegexp` steuert nur, welcher Router greift; die eigentliche Sperre ist `lan-only`.

**Nur mit Basic-Auth** (drogon – dort gibt es kein `lan-only`): nur der `-app`-Router, Middleware
`basic-auth-nils-only` oder `basic-auth-all`.

**Öffentlich** (Dienst mit eigener Anmeldung, bewusst von außen erreichbar): `-app`-Router ohne
`middlewares=`-Zeile. Nur nach ausdrücklicher Bestätigung durch Nils; danach die Ausnahmeliste in
CLAUDE.md und readme.md (Abschnitt „SSL Zertifikate") ergänzen.

## 4. Einträge

- **Playbook** `install_<host>.yml` unter „Docker Roles":
  ```yaml
      - role: <rolle>
        tags:
          - <rolle>
  ```
- **readme.md**, Liste „Dienste" alphabetisch: `- [<rolle>](<projekt-url>): <ein Satz>. (<host>)`
- **Vault**: nicht selbst anlegen. Nils die Liste geben, z.B.
  `ansible-vault create host_vars/<host>/<rolle>.vault.yml` mit `vault_<rolle>_example_secret: …`.

## 5. Prüfen

1. `ansible-playbook --syntax-check install_tyrion.yml install_drogon.yml < /dev/null`
2. `~/.local/bin/ansible-lint` (Exit 0) und `~/.local/pipx/venvs/ansible-lint/bin/yamllint .`
3. Jeder Router der neuen Rolle hat eine Middleware (außer bestätigt öffentlich):
   `grep -n "routers\..*\.rule=\|middlewares=" roles/<rolle>/templates/docker-compose.yml.j2`
4. Skill `compare-render` mit `--host <host>`: die **einzige** Abweichung dürfen die neuen Dateien
   der Rolle sein (neue Unit + `/data/<rolle>/…`), alle anderen Dienste unverändert.

## 6. Ergebnis an Nils

- angelegte/geänderte Dateien,
- Vault-Variablen, die er anlegen muss (vor dem ersten Lauf, sonst schlägt `| mandatory` zu),
- bei drogon: DNS-Eintrag, der vorher existieren muss,
- Dry-Run: `ansible-playbook install_<host>.yml --check --diff --tags <rolle>`
  (bei einer neuen Rolle kann der Start-Task im Check-Modus scheitern, weil die Unit auf dem Host noch
  nicht existiert – dann zählt der Diff davor),
- Commit-Vorschlag, z.B. `feat(<rolle>): add <dienst> on <host>`.
