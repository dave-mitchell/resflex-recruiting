#!/usr/bin/env bash
# Release this Claude Code plugin: bump the version, commit, push, and update the installed copy.
#
# Usage: ./release.sh "What changed" [patch|minor|major] [-y]
#   patch (default) 0.1.0 -> 0.1.1 · minor 0.1.0 -> 0.2.0 · major 0.1.0 -> 1.0.0
#   -y  skip the confirmation prompt
#
# Afterwards, run /reload-plugins in an open Claude Code session (or start a new one).

set -euo pipefail

usage() { sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }

message="" bump="patch" assume_yes=false
for arg in "$@"; do
  case "$arg" in
    patch|minor|major) bump="$arg" ;;
    -y|--yes) assume_yes=true ;;
    -h|--help) usage ;;
    *) [[ -z "$message" ]] && message="$arg" || usage ;;
  esac
done
[[ -n "$message" ]] || usage

cd "$(dirname "$0")"
plugin_json=".claude-plugin/plugin.json"
marketplace_json=".claude-plugin/marketplace.json"
[[ -f "$plugin_json" && -f "$marketplace_json" ]] || { echo "error: run from a plugin repo with $plugin_json and $marketplace_json" >&2; exit 1; }

json_field() { python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1]))[sys.argv[2]])' "$1" "$2"; }
plugin=$(json_field "$plugin_json" name)
marketplace=$(json_field "$marketplace_json" name)
old_version=$(json_field "$plugin_json" version)

# Refuse to release from a stale or diverged checkout.
branch=$(git rev-parse --abbrev-ref HEAD)
git fetch --quiet origin "$branch"
if [[ -n "$(git rev-list HEAD..origin/"$branch")" ]]; then
  echo "error: $branch is behind origin/$branch — run 'git pull' first" >&2; exit 1
fi
if [[ -z "$(git status --porcelain)" ]]; then
  echo "error: no changes to release" >&2; exit 1
fi

IFS=. read -r major minor patch <<<"$old_version"
case "$bump" in
  major) new_version="$((major + 1)).0.0" ;;
  minor) new_version="$major.$((minor + 1)).0" ;;
  patch) new_version="$major.$minor.$((patch + 1))" ;;
esac

echo "Releasing $plugin $old_version -> $new_version from $branch"
echo "Files to commit:"
git status --short | sed 's/^/  /'
if ! $assume_yes; then
  read -r -p "Continue? [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]] || { echo "Cancelled; nothing changed."; exit 1; }
fi

# Replace only the version value so the file's formatting is kept.
sed -i.bak -E "s/(\"version\"[[:space:]]*:[[:space:]]*\")$old_version\"/\1$new_version\"/" "$plugin_json" && rm "$plugin_json.bak"
[[ "$(json_field "$plugin_json" version)" == "$new_version" ]] || { echo "error: version bump failed" >&2; exit 1; }

git add -A
git commit --quiet -m "$message" -m "Release $plugin $new_version"
git push --quiet origin "$branch"
echo "Pushed $(git rev-parse --short HEAD) to origin/$branch"

claude plugin marketplace update "$marketplace"
claude plugin update "$plugin@$marketplace"

echo
echo "Done: $plugin $new_version installed. Run /reload-plugins in open sessions, or start a new one."
