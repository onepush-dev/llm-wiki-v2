# llm-wiki-v2 on Railway

[llm-wiki-v2](https://github.com/crow-hq/llm-wiki-v2) (AGPL-3.0) turns the sources you drop in into a Markdown wiki that an LLM keeps organised, and answers questions with citations. It works with OpenRouter, OpenAI, Gemini or any OpenAI-compatible server. Deploy it on Railway with one click.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/vknEJG)

Community packaging of upstream `v1.0.0` (image built unmodified from the upstream Dockerfile); not affiliated with the upstream authors.

## What you get
- One service: the upstream server on `127.0.0.1:8000` behind **Caddy basic auth** (upstream has no authentication). User `admin`, password `WIKI_PASSWORD` (generated per deploy, see the service Variables tab). `/health` stays open for the healthcheck.
- One volume at `/data`: the wiki itself (`/data/wiki`, plain OKF Markdown), settings saved from the page (`/data/config.json`) and the token usage log.
- No inputs needed. The LLM key is optional at deploy time.

## First use
1. Open the URL and sign in as `admin` / `WIKI_PASSWORD`.
2. Add a model key: open **Settings** (⚙) on the page and paste an OpenRouter key (it also serves the CROW classifier), or choose another provider. Alternatively set `OPENROUTER_API_KEY` (or `OPENAI_API_KEY` / `GEMINI_API_KEY` with `OKF_LLM_PROVIDER`) as a service variable. Without a classifier key, switch to classic mode (`OKF_MODE=classic`).
3. Drop in text or files to ingest, then ask questions.

The MCP memory (`/mcp`) can be turned on from the page; MCP clients must send the same basic-auth credentials (`Authorization: Basic ...`).

## Layout
- `app/Dockerfile` adds Caddy and the start script on top of the upstream image; `.github/workflows/publish-ghcr.yml` builds `ghcr.io/onepush-dev/llm-wiki-v2:1.0.0-r2`.
