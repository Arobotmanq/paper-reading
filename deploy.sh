#!/usr/bin/env bash
# One-command deploy: regenerate the 方法论 page + gallery, then push to GitHub Pages.
# The skill.html is rebuilt from the live SKILL.md every run, so the published
# "方法论" tab always mirrors the current skill.
set -e
SKILL="$HOME/.claude/skills/paper-reading/scripts"
/usr/bin/python3 "$SKILL/build_index.py"
/usr/bin/python3 "$SKILL/build_site.py"
cd "$HOME/Paper_reading"
git add -A
if git diff --cached --quiet; then
  echo "no changes to deploy."
else
  git commit -m "update $(date +'%Y-%m-%d %H:%M')"
  git push
  echo "pushed — GitHub Pages refreshes in ~1 min."
fi
