#!/usr/bin/env python3
"""Baut eine Seite (alt oder neu) des Nachbaus auf und schreibt play.yml.

Aufruf: prepare.py <seitenverzeichnis> <repo-host-vars-dir> <vars.yml> <rolle>...

- /etc-Ziele werden ins Seitenverzeichnis umgebogen, owner/group entfernt.
- Module, die lokal nicht laufen (systemd, apt, docker_network, git, initramfs),
  werden durch debug ersetzt; git wird nur ersetzt, wenn kein Test-Repo gesetzt ist.
- root kommt für alle Rollen aus einer Play-Variable (wie group_vars/all/services.yml).
"""
import glob
import re
import sys

import yaml

side, _hostvars, varsfile, *roles = sys.argv[1:]

STUB_MODULES = [
    "ansible.builtin.systemd",
    "ansible.builtin.apt",
    "community.docker.docker_network",
]

for path in (glob.glob(f"{side}/tasks/*.yml")
             + glob.glob(f"{side}/roles/*/tasks/*.yml")
             + glob.glob(f"{side}/roles/*/handlers/*.yml")):
    with open(path, encoding="utf-8") as f:
        s = f.read()
    s = s.replace('"/etc/', f'"{side}/etc/').replace("dest: /etc/", f"dest: {side}/etc/")
    s = re.sub(r"\n    owner: root", "", s)
    s = re.sub(r"\n    group: root", "", s)
    for mod in STUB_MODULES:
        s = re.sub(r"  " + re.escape(mod) + r":\n(    .*\n?)+",
                   f'  ansible.builtin.debug:\n    msg: "STUB {mod}"\n', s)
    s = re.sub(r"  ansible\.builtin\.command: sudo update-initramfs -u\n  changed_when: true",
               '  ansible.builtin.debug:\n    msg: "STUB initramfs"', s)
    with open(path, "w", encoding="utf-8") as f:
        f.write(s)

play = [{
    "name": "compare-render",
    "hosts": "localhost",
    "gather_facts": True,  # z.B. ansible_facts.date_time in Templates
    "vars_files": [varsfile],
    "vars": {"root": side + "/data/{{ role_name }}"},
    "roles": roles,
}]
with open(f"{side}/play.yml", "w", encoding="utf-8") as f:
    yaml.safe_dump(play, f, sort_keys=False)
