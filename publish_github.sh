#!/usr/bin/env bash
# One-time: create the GitHub repo, push, and turn on GitHub Pages.
# Prereq: you have authenticated once with `gh auth login`.
# After this, use ./deploy.sh for every future update.
set -e
export PATH="$HOME/.local/bin:$PATH"
REPO="${1:-paper-reading}"
cd "$HOME/Paper_reading"

if ! gh auth status >/dev/null 2>&1; then
  echo "!! Not logged in to GitHub. Run:  gh auth login"
  echo "   (choose: GitHub.com -> HTTPS -> Yes authenticate Git -> Login with a web browser)"
  exit 1
fi
OWNER="$(gh api user --jq .login)"
echo "GitHub user: $OWNER   repo: $REPO   (public)"

# create repo from current dir + push (idempotent: skip create if it already exists)
if gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
  echo "repo exists; pushing…"
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$OWNER/$REPO.git"
  git push -u origin main
else
  gh repo create "$REPO" --public --source=. --remote=origin --push \
    --description "VLA / 人形机器人论文阅读库 — 画廊 + 证据优先综述 + 推荐 + 方法论"
fi

# enable GitHub Pages on main / root (idempotent)
if gh api "repos/$OWNER/$REPO/pages" >/dev/null 2>&1; then
  echo "Pages already enabled."
else
  gh api -X POST "repos/$OWNER/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" >/dev/null \
    && echo "Pages enabled." || echo "(Pages enable returned an error — you can also flip it on in repo Settings → Pages → Branch: main /root)"
fi

URL="$(gh api "repos/$OWNER/$REPO/pages" --jq .html_url 2>/dev/null || echo "https://$OWNER.github.io/$REPO/")"
echo ""
echo "============================================================"
echo "  ✅ Published.  Your site (live in ~1 min, any computer):"
echo "     $URL"
echo "  Future updates:  ./deploy.sh"
echo "============================================================"
