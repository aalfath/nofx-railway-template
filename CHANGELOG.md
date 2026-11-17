# Changelog

Each entry is one version of this template. Breaking changes are listed first.
Deployers get an "update available" notice in Railway when a change is merged to `main`. Read the entry before you apply it.

## 2026.11.04-65e9037 (2026-11-17)

- First release: NOFX at upstream commit [`65e9037`](https://github.com/NoFxAiOS/nofx/commit/65e9037b452707c216d9746ea2c942fd1843badc) (head of `main` and `stable` on 2026-11-04; NOFX publishes no version tags).
- Images: `ghcr.io/nofxaios/nofx/nofx-backend:sha-65e9037-amd64@sha256:0f4759d6dc2e7b35c1c2419a83ef4ee255cc32eae336ae61304acfc17a0e02f9` and `ghcr.io/nofxaios/nofx/nofx-frontend:sha-65e9037-amd64@sha256:7356685d8fc1c2ffb07c4a4f2c33c67fcabfb8226bc217274cc7e0ff88d910e4`.
- One service: nginx on `PORT` serves the web UI and proxies `/api/` to the NOFX API on `127.0.0.1:8081`. SQLite database, logs, planning workspaces and the RSA key live on the `/app/data` volume.
- First-run gate: until the first account exists, the site asks for user `setup` and `SETUP_PASSWORD`.
