#!/bin/bash
# thermal-test.sh: 30 s all-core load, then report per-core peak temps and the spread.
# A healthy paste job: cores within ~8 C of each other, peak well under 90 C.
# Usage: thermal-test.sh [seconds]     (default 30)
S=${1:-30}
N=$(lscpu -p=Core,Socket | grep -v '^#' | sort -u | wc -l)   # physical cores
echo "Idle start: $(sensors | awk '/Package id 0/{print $4}')  - loading $N cores for ${S}s (Ctrl+C aborts)"
stress-ng --cpu "$N" --cpu-method matrixprod --timeout "${S}s" -q &
SP=$!
trap 'kill $SP 2>/dev/null' INT TERM
declare -A mx
for ((i = 0; i < S; i++)); do
  sleep 1
  while read -r k v; do
    v=${v%.*}; [ "${v:-0}" -gt "${mx[$k]:-0}" ] && mx[$k]=$v
  done < <(sensors | awk '/^Core [0-9]+:/{n="Core_"$2; t=$3} /^Package id 0:/{n="Package"; t=$4} /^(Core [0-9]+|Package id 0):/{gsub(/[+°C]/,"",t); sub(":","",n); print n, t}')
  printf "\r%2ds  pkg %s " "$((i + 1))" "$(sensors | awk '/Package id 0/{print $4}')"
done
wait "$SP" 2>/dev/null
echo; echo "Peak per sensor:"
lo=999; hi=0
for k in $(printf '%s\n' "${!mx[@]}" | sort); do
  echo "  ${k//_/ }: ${mx[$k]} C"
  case $k in Core_*) [ "${mx[$k]}" -lt "$lo" ] && lo=${mx[$k]}; [ "${mx[$k]}" -gt "$hi" ] && hi=${mx[$k]} ;; esac
done
echo "Core spread: $((hi - lo)) C"
