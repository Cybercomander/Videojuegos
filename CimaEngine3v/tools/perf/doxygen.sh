#!/usr/bin/env bash
# Genera la documentacion HTML con el Doxyfile del proyecto y la abre.
set -euo pipefail
RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$RAIZ"
command -v doxygen >/dev/null || { echo "Doxygen no esta instalado.  brew install doxygen graphviz"; exit 1; }
doxygen Doxyfile
open documentacion/html/index.html
