# EBM AI — Diesel Engine Diagnostic Platform

**Proprietary & Confidential — Revealiency LLC**

US Patent #10718284 B2 | Indian Patent #553370

---

## Overview

EBM AI is a cloud-based platform that collects diesel engine emission readings and runs them through the patented EBM algorithm to produce predictive maintenance diagnostics. The system supports both manual technician inputs and fully autonomous continuous monitoring via telematics hardware.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend API | Ruby on Rails 7.1 |
| Language | Ruby 3.2.2 |
| Database | PostgreSQL |
| Authentication | Devise + JWT |
| Background Jobs | Sidekiq |
| Hosting (API) | Render.com |
| Hosting (Frontend) | Lovable / Vercel |
| Cloud Storage | AWS S3 |

---

## Local Development Setup

### Prerequisites
- Ruby 3.2.2 (use [rbenv](https://github.com/rbenv/rbenv) or [asdf](https://asdf-vm.com))
- PostgreSQL 14+
- Redis (for Sidekiq background jobs)

### Steps

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_ORG/ebm-ai-app.git
cd ebm-ai-app

# 2. Install dependencies
bundle install

# 3. Set up environment variables
cp .env.example .env
# Edit .env with your values

# 4. Create and migrate the database
rails db:create db:schema:load db:seed

# 5. Start the server
rails server
```

---

## Deploying to Render.com

1. Connect your GitHub repo to Render
2. Create a new **Web Service** — Render will detect the `render.yaml`
3. Add environment variables from `.env.example` in the Render dashboard
4. Deploy

---

## Architecture

```
[Telematics Device] → FTP → [AWS S3] → [Lambda] → [EBM AI API]
                                                         ↓
[Lovable Frontend] ←────────────── JSON API ────── [Rails + PostgreSQL]
                                                         ↓
                                                   [Sidekiq Worker]
                                                         ↓
                                                   [Email Results]
```

---

## Key Files

| File | Purpose |
|------|---------|
| `app/models/output.rb` | EBM diagnostic algorithm (core patent IP) |
| `app/models/input.rb` | Emission reading data model |
| `app/models/vehicle_stat.rb` | Autonomous telematics data pipeline |
| `lambda/importVehicleStats.py` | AWS Lambda trigger for FTP→S3→API flow |
| `config/initializers/cors.rb` | CORS config for Lovable frontend |

---

## Security

- All credentials are stored in environment variables — never in code
- See `.env.example` for required variables
- JWT tokens used for API authentication
- CORS restricted to `FRONTEND_URL` environment variable

---

*Revealiency LLC — Confidential*
