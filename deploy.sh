#!/usr/bin/env bash
# One-command deploy: regenerate the 方法论 page + gallery, then push to GitHub Pages.
# The skill.html is rebuilt from the live SKILL.md every run, so the published
# "方法论" tab always mirrors the current skill.
set -e
SKILL="$HOME/.claude/skills/paper-reading/scripts"
# figures -> webp (keeps the live site light); needs conda base for Pillow
source "$HOME/anaconda3/etc/profile.d/conda.sh" 2>/dev/null && conda activate base 2>/dev/null
python3 "$SKILL/optimize_images.py" "$HOME/Paper_reading" || true
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
