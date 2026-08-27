#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Busca fugas de memoria con la herramienta "leaks" de macOS (equivalente local
# de Valgrind, que no existe en Apple Silicon).
#
#   uso: leaks-check.sh [Debug|Release|RelWithDebInfo]
#
# Compila el perfil pedido, lanza el juego con MallocStackLogging y, al cerrar
# la ventana, imprime el reporte de bloques no liberados con su stack trace.
#
# OJO: no lo uses con el perfil ASan (AddressSanitizer reemplaza malloc y el
# reporte sale vacio o con ruido).
# -----------------------------------------------------------------------------
set -euo pipefail

CFG="${1:-Debug}"
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$RAIZ"

echo ">> compilando perfil $CFG ..."
cmake --preset "$CFG" >/dev/null
cmake --build --preset "$CFG"

EXE="$RAIZ/bin/$CFG/CimaEngine3v"
[ -x "$EXE" ] || { echo "No encontre el ejecutable en $EXE"; exit 1; }

echo
echo ">> lanzando bajo 'leaks --atExit'. Cierra la ventana del juego para ver el reporte."
echo
exec leaks --atExit --groupByType -- "$EXE"
