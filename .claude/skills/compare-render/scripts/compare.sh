#!/usr/bin/env bash
# Vergleicht, was die Rollen auf einem Host erzeugen würden: Stand <ref> gegen Working Tree.
#
#   compare.sh <arbeitsverzeichnis> [--ref HEAD] [--host tyrion] [rolle ...]
#
# Ohne Rollen: alle Rollen, die docker-compose-service.yml nutzen – in EINEM Play, wie auf dem Host.
# Exit 0 = Pfade, Modi und Inhalt identisch und zweiter Lauf changed=0.
set -euo pipefail

usage() { sed -n '2,7p' "$0"; exit 2; }
[[ $# -ge 1 ]] || usage
WORK=$1; shift
REF=HEAD
HOST=tyrion
ROLES=()
while [[ $# -gt 0 ]]; do
  case $1 in
    --ref) REF=$2; shift 2 ;;
    --host) HOST=$2; shift 2 ;;
    -h|--help) usage ;;
    *) ROLES+=("$1"); shift ;;
  esac
done

REPO=$(git rev-parse --show-toplevel)
HERE=$(cd "$(dirname "$0")" && pwd)
PY=~/.local/pipx/venvs/ansible-lint/bin/python   # hat PyYAML
[[ -x $PY ]] || PY=python3

cd "$REPO"
if [[ ${#ROLES[@]} -eq 0 ]]; then
  # bash 3.2 (macOS) kennt kein mapfile
  while IFS= read -r r; do ROLES+=("$r"); done \
    < <(grep -l "docker-compose-service.yml" roles/*/tasks/main.yml | cut -d/ -f2)
fi
echo "Vergleich $REF -> Working Tree, Host $HOST, ${#ROLES[@]} Rollen"

rm -rf "$WORK"; mkdir -p "$WORK/site"
( cd "$WORK/site" && git init -q -b main && echo v1 > index.html && git add . \
  && git -c user.name=t -c user.email=t@t commit -qm v1 )

"$PY" "$HERE/genvars.py" "$REPO" "$HOST" "$WORK/site" "$WORK/vars.yml" "${ROLES[@]}"

for side in old new; do
  B=$WORK/$side
  mkdir -p "$B/etc/systemd/system" "$B/etc/logrotate.d" "$B/etc/modprobe.d"
  if [[ $side == old ]]; then
    git archive "$REF" roles tasks templates | tar -x -C "$B"
  else
    cp -R roles tasks templates "$B/"
  fi
  "$PY" "$HERE/prepare.py" "$B" "$REPO/host_vars/$HOST" "$WORK/vars.yml" "${ROLES[@]}"
  ( cd "$B" && ansible-playbook -i localhost, -c local play.yml > run1.log 2>&1 ) || {
    echo "FEHLER im Lauf ($side), siehe $B/run1.log:"; grep -E "fatal|ERROR" -A4 "$B/run1.log" | head -20; exit 1; }
  # Modi VOR jedem sed erfassen (macOS sed -i wendet die umask an)
  ( cd "$B" && find data etc -type f -not -path '*/.git/*' -print0 \
    | xargs -0 stat -f "%Lp %N" | sort -k2 > "$WORK/$side.modes" )
done

status=0
if diff "$WORK/old.modes" "$WORK/new.modes" > "$WORK/modes.diff"; then
  echo "OK   Pfade und Modi identisch ($(wc -l < "$WORK/new.modes" | tr -d ' ') Dateien)"
else
  echo "DIFF Pfade/Modi:"; cat "$WORK/modes.diff"; status=1
fi

for side in old new; do
  mkdir -p "$WORK/cmp/$side"
  cp -R "$WORK/$side/data" "$WORK/$side/etc" "$WORK/cmp/$side/"
  find "$WORK/cmp/$side" -name .git -type d -prune -exec rm -rf {} +
  find "$WORK/cmp/$side" -type f -exec sed -i '' "s#$WORK/$side/#SIDE/#g" {} +
done
if diff -r "$WORK/cmp/old" "$WORK/cmp/new" > "$WORK/content.diff"; then
  echo "OK   Inhalt identisch"
else
  echo "DIFF Inhalt (vollständig in $WORK/content.diff):"; head -40 "$WORK/content.diff"; status=1
fi

run2=$(cd "$WORK/new" && ansible-playbook -i localhost, -c local play.yml 2>&1 | grep -E "ok=")
if grep -q "changed=0" <<< "$run2"; then
  echo "OK   zweiter Lauf changed=0"
else
  echo "DIFF zweiter Lauf nicht idempotent: $run2"; status=1
fi
exit $status
