#!/bin/bash
# 사이트를 Cloudflare Pages 프로젝트 lemy0715에 올리고 lemy0715.mycsbot.com에 연결해요. (~/gitrepo/appintoss/scripts/deploy-pages.sh와 같은 방식)
set -eu
NAME=lemy0715
ZONE=mycsbot.com
HOST=$NAME.$ZONE
TOKENS=${CLOUDFLARE_TOKEN_DIR:-$HOME/.config/cloudflare-api-tokens}
DNS=${CLOUDFLARE_DNS_SCRIPT:-$HOME/gitrepo/skills/lemy0715/cloudflare-dns/scripts/cloudflare_dns.py}
API=https://api.cloudflare.com/client/v4
export CLOUDFLARE_ACCOUNT_ID=04aff0f119c274d097655b02561a343e
CLOUDFLARE_API_TOKEN=$(cat "$TOKENS/account.pages.api-token")
export CLOUDFLARE_API_TOKEN
cd "$(dirname "$0")"

node readme.mjs
OUT=$(mktemp -d)
cp -R index.html projects.json img "$OUT/"

pages() {
  curl -sS -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" -H 'Content-Type: application/json' \
    "$API/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/$NAME$1" "${@:2}"
}
# 프로젝트가 이미 있으면 만들기는 실패해도 괜찮아요
curl -sS -X POST -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" -H 'Content-Type: application/json' \
  "$API/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects" -d "{\"name\":\"$NAME\",\"production_branch\":\"main\"}" >/dev/null || true
npx wrangler pages deploy "$OUT" --project-name "$NAME" --branch main --commit-dirty=true

TARGET=$(pages "" | python3 -c 'import json,sys; print(json.load(sys.stdin)["result"]["subdomain"])')
pages /domains -X POST -d "{\"name\":\"$HOST\"}" >/dev/null || true
python3 "$DNS" upsert "$ZONE" --type CNAME --name "$HOST" --content "$TARGET" --ttl 1 --proxied true >/dev/null
echo "배포 완료: https://$HOST  ($TARGET)"
echo "도메인 상태: $(pages "/domains/$HOST" | python3 -c 'import json,sys; print((json.load(sys.stdin).get("result") or {}).get("status"))')"
