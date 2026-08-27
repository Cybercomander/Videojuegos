#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Graba una traza de Instruments (Xcode) del motor y la abre al terminar.
#
#   uso: instruments.sh "<plantilla>" [Debug|Release|RelWithDebInfo|ASan]
#
# Plantillas utiles:
#   "Time Profiler"   -> donde se va el CPU, por funcion y por hilo
#   "Allocations"     -> cuanta RAM se pide, quien la pide y cuanta sigue viva
#   "Leaks"           -> fugas
#   "Game Performance"-> frames, GPU y CPU juntos
#
# Las trazas se guardan en CimaEngine3v/.cache/traces (ignorado por git).
# -----------------------------------------------------------------------------
set -euo pipefail

PLANTILLA="${1:?Falta la plantilla, ej: \"Time Profiler\"}"
CFG="${2:-RelWithDebInfo}"
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$RAIZ"

echo ">> compilando perfil $CFG ..."
cmake --preset "$CFG" >/dev/null
cmake --build --preset "$CFG"

EXE="$RAIZ/bin/$CFG/CimaEngine3v"
[ -x "$EXE" ] || { echo "No encontre el ejecutable en $EXE"; exit 1; }

mkdir -p "$RAIZ/.cache/traces"
SLUG="$(echo "$PLANTILLA" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
TRAZA="$RAIZ/.cache/traces/${SLUG}-$(date +%Y%m%d-%H%M%S).trace"

echo
echo ">> grabando \"$PLANTILLA\". Juega un rato y cierra la ventana para terminar."
echo
xcrun xctrace record --template "$PLANTILLA" --output "$TRAZA" --launch -- "$EXE"

echo
echo ">> traza guardada en: $TRAZA"
open "$TRAZA"
