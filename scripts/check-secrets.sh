#!/usr/bin/env bash
set -euo pipefail

# Lightweight pre-commit/public-repo safety check. This does not replace a full
# scanner such as gitleaks, but catches common accidental leaks and local state.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

forbidden_paths='(^|/)(auth\.json|github-credentials|.*\.sock|.*\.log|session\.json|config-gpui\.lock|\.plugins\.lock)$|(^|/)\.git(/|$)|(^|/)node_modules(/|$)|(^|/)\.local(/|$)'
if find . -path './.git' -prune -o -type f -print | grep -E "$forbidden_paths"; then
  echo "Refusing to publish local state or credential-like files listed above." >&2
  exit 1
fi

secret_patterns='((api[_-]?key|access[_-]?token|refresh[_-]?token|client[_-]?secret|private[_-]?key|password|passwd)[[:space:]]*[:=][[:space:]]*["'\'' ]?[A-Za-z0-9._~+/=-]{8,}|bearer [A-Za-z0-9._~+/=-]{16,}|sk-[A-Za-z0-9_-]{20,}|gh[pousr]_[A-Za-z0-9_]{20,})'
if grep -RInE --exclude-dir=.git --exclude='check-secrets.sh' "$secret_patterns" .; then
  echo "Potential secret found. Review before publishing." >&2
  exit 1
fi

echo "No obvious secrets or local runtime files found."
