#!/usr/bin/env python3
"""Erzeugt die Rollenliste in readme.md.

Quellen:
- roles/                  welche Rollen es gibt; System-Rolle = keine templates/docker-compose.yml.j2
- install_<host>.yml      auf welchem Host eine Rolle aktiv ist (auskommentiert = nicht aktiv)
- docs/roles.yml          Beschreibung und Projekt-Link je Rolle

Ersetzt den Bereich zwischen den ROLLENLISTE-Markern in readme.md.
Aufruf: scripts/update_readme.py [--check]   (--check: nur prüfen, Exit 1 bei Abweichung)
Wird von pre-commit ausgeführt (.pre-commit-config.yaml).
"""
import glob
import os
import re
import sys

import yaml

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
README = os.path.join(ROOT, "readme.md")
DOCS = os.path.join(ROOT, "docs", "roles.yml")
BEGIN = "<!-- BEGIN ROLLENLISTE: automatisch erzeugt von scripts/update_readme.py, Texte in docs/roles.yml -->"
END = "<!-- END ROLLENLISTE -->"


def active_roles_per_host():
    hosts = {}
    for path in sorted(glob.glob(os.path.join(ROOT, "install_*.yml"))):
        host = re.match(r"install_(.+)\.yml$", os.path.basename(path)).group(1)
        names = set()
        for play in yaml.safe_load(open(path, encoding="utf-8")) or []:
            for entry in play.get("roles") or []:
                names.add(entry["role"] if isinstance(entry, dict) else entry)
        hosts[host] = names
    return hosts


def main():
    check = "--check" in sys.argv[1:]
    roles = sorted(d for d in os.listdir(os.path.join(ROOT, "roles"))
                   if os.path.isdir(os.path.join(ROOT, "roles", d)))
    docs = yaml.safe_load(open(DOCS, encoding="utf-8")) or {}

    errors = [f"Rolle '{r}' fehlt in docs/roles.yml" for r in roles if r not in docs]
    errors += [f"docs/roles.yml nennt '{r}', die Rolle gibt es nicht" for r in docs if r not in roles]
    if errors:
        print("\n".join(errors))
        return 1

    hosts = active_roles_per_host()

    def line(role):
        entry = docs[role]
        name = f"[{role}]({entry['url']})" if entry.get("url") else role
        text = f"{name}: {entry['description']}"
        on = [h for h in hosts if role in hosts[h]]
        if not on:
            return f"- ~~{text}~~"
        where = "beide" if len(on) == len(hosts) and len(hosts) > 1 else ", ".join(on)
        return f"- {text} ({where})"

    system = [r for r in roles
              if not os.path.exists(os.path.join(ROOT, "roles", r, "templates", "docker-compose.yml.j2"))]
    services = [r for r in roles if r not in system]
    block = "\n".join([
        BEGIN,
        "",
        "### System-Rollen",
        "",
        *[line(r) for r in system],
        "",
        "### Dienste",
        "",
        *[line(r) for r in services],
        "",
        END,
    ])

    readme = open(README, encoding="utf-8").read()
    if BEGIN not in readme or END not in readme:
        print(f"readme.md: Marker fehlen ({BEGIN} ... {END})")
        return 1
    start = readme.index(BEGIN)
    stop = readme.index(END) + len(END)
    new = readme[:start] + block + readme[stop:]
    if new == readme:
        return 0
    if check:
        print("readme.md: Rollenliste ist nicht aktuell – scripts/update_readme.py ausführen")
        return 1
    with open(README, "w", encoding="utf-8") as f:
        f.write(new)
    print("readme.md: Rollenliste aktualisiert")
    return 0


if __name__ == "__main__":
    sys.exit(main())
