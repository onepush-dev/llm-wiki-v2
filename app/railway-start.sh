#!/bin/bash
# llm-wiki-v2 on Railway: the upstream server on 127.0.0.1:8000 (it has no authentication of its own),
# behind Caddy basic auth on $PORT. /health stays open for the Railway healthcheck.
set -euo pipefail
: "${PORT:=8080}"
: "${WIKI_USER:=admin}"
: "${WIKI_PASSWORD:?WIKI_PASSWORD is required}"
mkdir -p "$OKF_BUNDLE" "$(dirname "$OKF_CONFIG")"
chown -R wiki:wiki /data
export WIKI_HASH="$(caddy hash-password --plaintext "$WIKI_PASSWORD")"
cat > /tmp/Caddyfile <<'CADDY'
{
	admin off
	auto_https off
}
:{$PORT} {
	handle /health {
		reverse_proxy 127.0.0.1:8000 {
			header_up Host localhost:8000
		}
	}
	handle {
		basic_auth {
			{$WIKI_USER} {env.WIKI_HASH}
		}
		# The wiki only answers requests addressed to localhost and refuses cross-site writes.
		# Authenticated same-origin requests are presented as local (so Settings can be edited from the page);
		# any other Origin is passed through unchanged and the wiki refuses it.
		@same expression {header.Origin} == "https://" + {host} || {header.Origin} == "http://" + {host}
		handle @same {
			reverse_proxy 127.0.0.1:8000 {
				header_up Host localhost:8000
				header_up Origin http://localhost:8000
				header_up X-Author {http.auth.user.id}
				flush_interval -1
			}
		}
		handle {
			reverse_proxy 127.0.0.1:8000 {
				header_up Host localhost:8000
				header_up X-Author {http.auth.user.id}
				flush_interval -1
			}
		}
	}
}
CADDY
setpriv --reuid=wiki --regid=wiki --clear-groups llmwiki2 serve --host 127.0.0.1 --port 8000 &
APP=$!
caddy run --config /tmp/Caddyfile --adapter caddyfile &
PROXY=$!
# Stop the container (Railway restarts it) if either process exits.
wait -n "$APP" "$PROXY"
kill "$APP" "$PROXY" 2>/dev/null || true
exit 1
