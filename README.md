# Deploy and Host NOFX on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/nofx-3?utm_medium=integration&utm_source=button&utm_campaign=nofx)

NOFX is an open-source (AGPL-3.0), self-hosted AI trading terminal. You connect your own AI model keys (DeepSeek, OpenAI, Claude, Gemini, Qwen and others) and your exchange or broker accounts, then build strategies, review AI-generated trade plans and run AI traders for crypto, US stocks, forex and commodities from one web dashboard.

## About Hosting NOFX

This template runs NOFX as one Railway service built from a small public wrapper repo. The official NOFX backend binary and web UI images are pinned by commit and digest; nginx serves the UI on Railway's `PORT` and proxies the API, which only listens inside the container. The SQLite database, logs, planning workspaces and the RSA transport key are kept on a Railway volume, so accounts, API keys and trader settings survive redeploys and restarts. The JWT, data-encryption and setup secrets are generated per deploy. Until you create the first account, the whole site asks for a setup password, so nobody else can claim your instance.

## Common Use Cases

* Run AI traders that analyse markets and place orders on your own exchange accounts (Binance, Bybit, OKX, Bitget, Hyperliquid and others)
* Build and compare trading strategies and AI-generated trade plans before risking money
* Keep exchange and model API keys encrypted on infrastructure you control instead of a hosted service

## Dependencies for NOFX Hosting

* An API key for at least one AI model provider, added in the NOFX web UI after deploy
* An exchange or broker account with API access, added in the NOFX web UI

### Deployment Dependencies

* [NOFX repository and documentation](https://github.com/NoFxAiOS/nofx)
* [NOFX commit 65e9037 (pinned)](https://github.com/NoFxAiOS/nofx/commit/65e9037b452707c216d9746ea2c942fd1843badc)
* [Wrapper repository for this template](https://github.com/aalfath/nofx-railway-template)
* [Railway volumes](https://docs.railway.com/reference/volumes)

### Implementation Details

**After deploy:** open the service's Variables tab and copy `SETUP_PASSWORD`. Open the public URL, sign in to the browser prompt with user `setup` and that password, then create your NOFX account (email and a password of at least 8 characters). NOFX is single-operator: registration closes after the first account and the setup prompt goes away. Then add your AI model and exchange keys under Config.

| Service | Source | Networking | Storage |
| --- | --- | --- | --- |
| nofx | `aalfath/nofx-railway-template` | public domain on 8080, health check `/health` | volume at `/app/data` |

| Variable | Default | Purpose |
| --- | --- | --- |
| `SETUP_PASSWORD` | generated secret | Password for the first-run prompt (user `setup`) |
| `JWT_SECRET` | generated secret | Signs login sessions; changing it signs everyone out |
| `DATA_ENCRYPTION_KEY` | generated secret | Encrypts stored API keys; never change it after setup |
| `PORT` | `8080` | Port nginx listens on |

Optional variables: `TZ` (default `UTC`), `AI_MAX_TOKENS` (default `8000`), `EXPERIENCE_IMPROVEMENT=false` to turn off NOFX's anonymous usage statistics, `TRANSPORT_ENCRYPTION=true` to encrypt API keys in the browser before sending.

Forgot your password? Run `/app/nofx reset-password --email YOUR-EMAIL` in the service's shell (`railway ssh`).

**Updates:** the wrapper repo pins NOFX by commit and image digest. When a newer NOFX is tested, the change is merged to the repo's `main` branch with a `CHANGELOG.md` entry, and Railway shows you an "update available" notice. Your data stays on the volume. Back up the volume before applying updates that the changelog marks as breaking.

Trading is risky and NOFX can place real orders with real money. This is a community-maintained deployment package and does not imply affiliation with or endorsement by the NOFX project.

## Why Deploy NOFX on Railway?

<!-- Recommended: Keep this section as shown below -->
Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying NOFX on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
<!-- End recommended section -->
