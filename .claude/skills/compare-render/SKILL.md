---
name: compare-render
description: Weist lokal nach, ob eine Änderung an Rollen, Templates oder tasks/ auf tyrion oder drogon etwas verändern würde – vergleicht die erzeugten Dateien (Pfade, Modi, Inhalt) und die Idempotenz zwischen einem Git-Stand und dem Working Tree. Verwenden vor jedem Commit-Vorschlag, der roles/, tasks/, templates/ oder group_vars/all/services.yml berührt, und immer bei Refactorings, die "auf den Hosts nichts ändern" sollen.
---

# compare-render

Rendert alle Docker-Dienst-Rollen zweimal in einem lokalen Nachbau – einmal mit dem Stand
`--ref` (Default `HEAD`), einmal mit dem Working Tree – und vergleicht das Ergebnis.
Nichts davon berührt einen Host.

## Aufruf

```bash
.claude/skills/compare-render/scripts/compare.sh <arbeitsverzeichnis> [--ref HEAD] [--host tyrion|drogon] [rolle ...]
```

- `<arbeitsverzeichnis>`: ein Verzeichnis im Scratchpad der Sitzung, z.B. `$SCRATCHPAD/compare`.
  Es wird vorher gelöscht.
- Ohne Rollen: alle Rollen, die `docker-compose-service.yml` nutzen, in **einem** Play – so wie auf
  dem Host. Das ist der Normalfall: nur so fällt auf, wenn eine Variable aus den Defaults einer Rolle
  bei anderen Rollen landet.
- Einzelne Rollen nur für schnelle Zwischenstände. Der volle Lauf dauert rund 3 Minuten.
- `--host` lädt die unverschlüsselten `host_vars` dieses Hosts (wichtig für traefik: Challenge,
  Dynamic Configs).

## Ergebnis lesen

Exit 0, wenn alle drei Zeilen `OK` sind:

1. **Pfade und Modi** – erfasst vor jeder Nachbearbeitung, also verlässlich auch für 664/1777.
2. **Inhalt** – Testpfade sind auf `SIDE/` normalisiert; volle Abweichung in `<arbeitsverzeichnis>/content.diff`.
3. **Zweiter Lauf `changed=0`** – Idempotenz des neuen Stands.

Jede `DIFF`-Zeile heißt: auf dem Host ändert sich diese Datei → der Dienst startet neu. Das ist nicht
automatisch falsch (z.B. gewollte Moduswechsel), muss aber im Ergebnis an Nils genannt werden –
mit Host und betroffenen Diensten.

## Was der Nachbau nicht abdeckt

Immer mit angeben, wenn es für die Änderung relevant ist:

- **Echte Secrets und Vault**: Templates bekommen Platzhalter (`dummy-<name>`). Fehlende oder
  umbenannte Vault-Variablen fallen hier nicht auf.
- **systemd, apt, docker_network, update-initramfs** sind durch `debug` ersetzt: Reihenfolge der
  Handler ist sichtbar, ihr Verhalten auf dem Host nicht (Mounts, `RequiresMountsFor`, Restarts).
- **Rollen ohne `docker-compose-service.yml`** (`admin_users`, `docker`, `ssh_hardening`,
  `system_config`) laufen nicht mit – dort per Syntax-Check, Lint und Textsuche prüfen.
- **Git-Checkout** des webservers nutzt ein lokales Test-Repo.
- Fakten stammen vom Mac (`gather_facts`), nicht vom Host.

## Wenn der Lauf selbst scheitert

`FEHLER im Lauf (old|new)` zeigt die ersten Fehlerzeilen, das volle Log liegt in
`<arbeitsverzeichnis>/<seite>/run1.log`. Typische Ursachen:

- neue Variable ohne Platzhalter, z.B. aus einem Lookup → in `scripts/genvars.py` ergänzen;
- neues Modul, das lokal nicht läuft → in `STUB_MODULES` in `scripts/prepare.py` ergänzen;
- die alte Seite (`--ref`) nutzt noch eine Struktur, die der Nachbau nicht kennt → älteres `--ref`
  nur mit einzelnen Rollen vergleichen.

## Hinweise zur Umgebung

- Die Skripte laufen mit dem Python aus `~/.local/pipx/venvs/ansible-lint` (hat PyYAML) und mit
  macOS-bash 3.2 – kein `mapfile`, keine assoziativen Arrays.
- Nicht aus zsh-Einzeilern nachbauen: zsh teilt `$VAR` nicht an Leerzeichen.
