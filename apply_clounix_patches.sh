#!/usr/bin/env bash
set -euo pipefail

PATCH_DIRS=("platform/clounix/patch" "platform/clounix/patch/build")

for PATCH_DIR in "${PATCH_DIRS[@]}"; do
  if [[ ! -d "$PATCH_DIR" ]]; then
    echo "Patch directory not found: $PATCH_DIR" >&2
    continue
  fi

  for patch in "$PATCH_DIR"/*.patch; do
    [[ -e "$patch" ]] || continue

    # Derive target module from patch name: anything-for-<folder>.patch -> src/<folder>
    module_name=$(basename "$patch" | sed -n 's/.*-for-\([^.]*\)\.patch/\1/p')
    if [[ -z "$module_name" ]]; then
      echo "Skip $patch: cannot derive module name" >&2
      continue
    fi

    target_dir="src/$module_name"
    if [[ ! -d "$target_dir" ]]; then
      echo "Skip $patch: target dir not found $target_dir" >&2
      continue
    fi

    echo "Applying $(basename "$patch") -> $target_dir"
    (
      cd "$target_dir"
      git apply --whitespace=fix "$OLDPWD/$patch"
    )
  done
done

echo "Done."
