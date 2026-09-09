#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
runs="${root}/librelane/runs"
latest="$(find "${runs}" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)"
test -n "${latest}" || { echo "ERROR: no LibreLane run found"; exit 1; }

out="${root}/evidence/$(basename "${latest}")"
mkdir -p "${out}"
python3 "${root}/scripts/summarize_ppa.py" "${runs}" > "${out}/ppa_summary.txt"

for pattern in '*.gds' '*.lef' '*.def' '*.nl.v' '*.sdf' 'metrics.json' 'metrics.csv'; do
  while IFS= read -r file; do
    cp -f "${file}" "${out}/"
  done < <(find "${latest}" -type f -name "${pattern}" | sort)
done

find "${out}" -maxdepth 1 -type f -printf '%f\n' | sort > "${out}/MANIFEST.txt"
echo "Evidence: ${out}"
