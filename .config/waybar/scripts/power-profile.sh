#!/usr/bin/env bash
set -euo pipefail

profile=$(busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile 2>/dev/null | awk '{print $2}' | tr -d '"')
printf '{"text": "%s", "class": "%s"}\n' "${profile}" "${profile}"
