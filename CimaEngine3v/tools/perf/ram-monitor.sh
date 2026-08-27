#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Monitor de RAM y CPU en vivo del proceso del motor, dentro de la ventana Run
# de CLion.
#
#   uso: ram-monitor.sh [nombre_proceso] [intervalo_seg]
#
# Arranca primero el juego con cualquier configuracion de Run/Debug; este script
# lo engancha por nombre y va imprimiendo el consumo hasta que el juego cierra.
# -----------------------------------------------------------------------------
set -uo pipefail

PROC="${1:-CimaEngine3v}"
INTERVALO="${2:-1}"

printf 'Esperando a que arranque "%s" ...\n' "$PROC"
PID=""
while [ -z "$PID" ]; do
    PID="$(pgrep -x "$PROC" | head -1 || true)"
    [ -z "$PID" ] && sleep 1
done

printf 'Enganchado a PID %s\n\n' "$PID"
printf '%-10s %10s %10s %8s %8s  %s\n' "hora" "RSS(MB)" "pico(MB)" "CPU%" "MEM%" "uso de RAM"
printf '%s\n' "----------------------------------------------------------------------------------"

PICO=0
while kill -0 "$PID" 2>/dev/null; do
    LINEA="$(ps -o rss=,%cpu=,%mem= -p "$PID" 2>/dev/null)"
    [ -z "$LINEA" ] && break

    RSS_KB="$(echo "$LINEA" | awk '{print $1}')"
    CPU="$(echo "$LINEA"    | awk '{print $2}')"
    MEM="$(echo "$LINEA"    | awk '{print $3}')"
    RSS_MB="$(awk -v k="$RSS_KB" 'BEGIN{printf "%.1f", k/1024}')"

    if awk -v a="$RSS_MB" -v b="$PICO" 'BEGIN{exit !(a>b)}'; then PICO="$RSS_MB"; fi

    # barra proporcional: 1 bloque = 16 MB, maximo 40 bloques
    BARRA="$(awk -v m="$RSS_MB" 'BEGIN{n=int(m/16); if(n>40)n=40; s=""; for(i=0;i<n;i++)s=s"#"; print s}')"

    printf '%-10s %10s %10s %8s %8s  %s\n' "$(date +%H:%M:%S)" "$RSS_MB" "$PICO" "$CPU" "$MEM" "$BARRA"
    sleep "$INTERVALO"
done

printf '\n%s\n' "----------------------------------------------------------------------------------"
printf 'El proceso %s termino.  Pico de RSS: %s MB\n' "$PID" "$PICO"
