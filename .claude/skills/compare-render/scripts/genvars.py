#!/usr/bin/env python3
"""Erzeugt Platzhalter-Variablen für alle Templates der Rollen und legt die
unverschlüsselten host_vars des Hosts darüber (ohne Werte, die auf vault_ zeigen).

Aufruf: genvars.py <repo> <host> <site-repo> <ausgabe.yml> <rolle>...
"""
import glob
import os
import re
import sys

import yaml

repo, host, site, out, *roles = sys.argv[1:]

# Variablen, die aus Rollen-Defaults, Play oder magischen Variablen kommen
SKIP = {"role_name", "root", "item", "loop", "ansible_facts", "inventory_hostname",
        "hostvars", "lookup", "query", "range", "omit"}

values = {}
for role in roles:
    for path in glob.glob(f"{repo}/roles/{role}/**/*", recursive=True):
        if not os.path.isfile(path) or "/defaults/" in path:
            continue
        try:
            text = open(path, encoding="utf-8").read()
        except UnicodeDecodeError:
            continue
        for expr in re.findall(r"\{\{(.*?)\}\}", text):
            m = re.match(r"\s*([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)", expr)
            if not m:
                continue
            parts = m.group(1).split(".")
            if parts[0] in SKIP:
                continue
            node = values
            for key in parts[:-1]:
                if not isinstance(node.get(key), dict):
                    node[key] = {}
                node = node[key]
            node.setdefault(parts[-1], "dummy-" + "-".join(parts))

# Rollen-Defaults würden sonst von den Platzhaltern überschrieben
for role in roles:
    path = f"{repo}/roles/{role}/defaults/main.yml"
    if os.path.exists(path):
        for key in (yaml.safe_load(open(path, encoding="utf-8")) or {}):
            values.pop(key, None)

for path in sorted(glob.glob(f"{repo}/host_vars/{host}/*.yml")):
    if path.endswith(".vault.yml"):
        continue
    for key, val in (yaml.safe_load(open(path, encoding="utf-8")) or {}).items():
        if "vault_" not in str(val):
            values[key] = val

values["webserver_git_repo"] = site
yaml.safe_dump(values, open(out, "w", encoding="utf-8"))
