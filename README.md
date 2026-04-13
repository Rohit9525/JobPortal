# CareerBridge — Your Bridge to Career Success

A production-ready, microservices job portal built with **React + TypeScript** (frontend) and **Spring Boot 3** (backend). Features job posting, applications with resume upload, OTP email verification, real-time SSE notifications, and role-based dashboards for Job Seekers, Recruiters, and Admins.

---

## Quick Start (Docker — Recommended)

### Prerequisites
- Docker Desktop ≥ 4.x with at least **8 GB RAM** allocated
- `docker compose` v2 (bundled with Docker Desktop)

### 1. Configure environment variables

```bash
cd backend
cp .env.example .env
# Edit .env and fill in:
#   JWT_SECRET          — at least 64 random chars
#   MYSQL_ROOT_PASSWORD — strong root password
#   MYSQL_USERNAME / MYSQL_PASSWORD
#   CLOUDINARY_*        — from cloudinary.com (free tier works)
#   MAIL_USERNAME / MAIL_PASSWORD — Gmail + App Password
```

### 2. Start the stack

**Core services** (auth, jobs, applications, files, gateway, frontend):
```bash
cd backend
./build.sh
```

**Full stack** (includes notification + admin services):
```bash
cd backend
./build.sh full
```

### 3. Access the app

| Service | URL |
|---------|-----|
| Frontend | http://localhost:3000 |
| API Gateway | http://localhost:8080 |
| Eureka Dashboard | http://localhost:8761 |
| Config Server | http://localhost:8888 |
| Notification Service | http://localhost:8085 (full profile only) |
| Admin Service | http://localhost:8086 (full profile only) |

### Default admin credentials
```
Email:    admin@jobportal.com
Password: Admin@123
```

---

## Dev Mode (Local Spring Boot + Vite)

Ideal for active development — hot-reload on both frontend and backend.

### 1. Start infrastructure only
```bash
cd backend
./start-dev.sh
```

### 2. Start backend services (in order, separate terminals)
```bash
cd backend/eureka-server    && mvn spring-boot:run
cd backend/config-server    && mvn spring-boot:run
cd backend/auth-service     && mvn spring-boot:run
cd backend/job-service      && mvn spring-boot:run
cd backend/application-service && mvn spring-boot:run
cd backend/file-service     && mvn spring-boot:run
cd backend/notification-service && mvn spring-boot:run  # optional
cd backend/admin-service    && mvn spring-boot:run      # optional
cd backend/api-gateway      && mvn spring-boot:run
```

### 3. Start the frontend
```bash
cd frontend
npm install
npm run dev
# → http://localhost:3000 (with HMR)
```

---

## Architecture

```
Browser
  └─ React SPA (port 3000 in dev / nginx in Docker)
       └─ Axios → API Gateway :8080
                    ├─ /api/v1/auth/**       → auth-service     :8081
                    ├─ /api/v1/jobs/**       → job-service      :8082
                    ├─ /api/v1/applications/**→ application-svc  :8083
                    ├─ /api/v1/files/**      → file-service     :8084
                    ├─ /api/v1/notifications/**→ notification-svc:8085
                    └─ /api/v1/admin/**      → admin-service    :8086

Infrastructure
  ├─ MySQL 8          :3307 (host) / 3306 (internal)
  ├─ Redis 7          :6379
  ├─ Apache Kafka     :9092  (via Zookeeper :2181)
  ├─ Eureka Server    :8761  (service discovery)
  └─ Config Server    :8888  (native config from config-repo/)
```

### Inter-service communication
- **Synchronous**: Spring Cloud OpenFeign (with Resilience4j circuit breaker fallbacks)
- **Asynchronous**: Apache Kafka events (`user-events`, `job-events`, `application-events`)
- **Real-time**: Server-Sent Events (SSE) from notification-service to browser

### Authentication flow
1. User registers → email OTP verified via Redis → JWT issued
2. JWT contains `userId`, `email`, `role` (e.g. `ROLE_JOB_SEEKER`)
3. API Gateway validates JWT and injects `X-User-Id`, `X-User-Email`, `X-User-Role` headers
4. Downstream services trust these headers — no re-validation needed

---

## Service Port Reference

| Service | Port |
|---------|------|
| Frontend (nginx) | 3000 |
| API Gateway | 8080 |
| Auth Service | 8081 |
| Job Service | 8082 |
| Application Service | 8083 |
| File Service | 8084 |
| Notification Service | 8085 |
| Admin Service | 8086 |
| Eureka Server | 8761 |
| Config Server | 8888 |
| MySQL | 3307 (host) |
| Redis | 6379 |
| Kafka | 9092 |

---

## User Roles

| Role | Capabilities |
|------|-------------|
| `JOB_SEEKER` | Browse jobs, apply with resume/cover letter, track applications, SSE notifications |
| `RECRUITER` | Post/edit/delete jobs, review applicants, update application status |
| `ADMIN` | All of the above + user management, analytics dashboard |

---

## Environment Variables Reference

| Variable | Required | Description |
|----------|----------|-------------|
| `JWT_SECRET` | ✅ | HS256 signing key — minimum 64 characters |
| `MYSQL_ROOT_PASSWORD` | ✅ | MySQL root password |
| `MYSQL_USERNAME` | ✅ | App DB user |
| `MYSQL_PASSWORD` | ✅ | App DB password |
| `CLOUDINARY_CLOUD_NAME` | ✅ | Cloudinary cloud name |
| `CLOUDINARY_API_KEY` | ✅ | Cloudinary API key |
| `CLOUDINARY_API_SECRET` | ✅ | Cloudinary API secret |
| `MAIL_USERNAME` | ✅ | Gmail address for sending emails |
| `MAIL_PASSWORD` | ✅ | Gmail App Password (not your Gmail password) |

> **Gmail App Password**: Go to Google Account → Security → 2-Step Verification → App Passwords

---

## Troubleshooting

### Services fail to start / health checks time out
Spring Boot services on slow machines can take 90–120 s to start. The `start_period` in docker-compose is already tuned for this. Wait 3–5 minutes after `./build.sh` finishes before investigating.

```bash
cd backend
./build.sh logs auth-service     # tail a specific service
./build.sh status                # see all container statuses
```

### MySQL connection refused
The `init.sql` and `init.sh` scripts in `docker/mysql/` pre-create all databases and grant permissions. If MySQL fails to initialise, remove the volume and restart:
```bash
docker volume rm careerbridge-mysql-data
./build.sh
```

### Notification / admin services not running
These are in the `full` Docker Compose profile. Start them with:
```bash
./build.sh full
# or if already running core:
docker compose --profile full up -d notification-service admin-service
```

### OTP emails not arriving
1. Verify `MAIL_USERNAME` and `MAIL_PASSWORD` in `.env`
2. Ensure Gmail 2FA is enabled and you are using an **App Password** (16-char, no spaces)
3. Check notification-service logs: `./build.sh logs notification-service`

### Port already in use
```bash
# Find and kill the process using a port, e.g. 8080:
lsof -ti:8080 | xargs kill -9   # macOS/Linux
netstat -ano | findstr :8080      # Windows PowerShell
```

### Full clean restart
```bash
cd backend
./build.sh clean    # removes containers + dangling images
./build.sh full     # fresh start
```

---

## Running Tests

### Frontend
```bash
cd frontend
npm test                 # watch mode
npm run test:coverage    # coverage report
```

### Backend (per service)
```bash
cd backend/auth-service
mvn test
```

---

## AWS Deployment + CI/CD (GitHub Actions + Docker Hub)

This repository now includes:

- GitHub Actions workflow: `.github/workflows/cicd-aws-dockerhub.yml`
- AWS deploy compose file: `deploy/docker-compose.aws.yml`
- AWS deploy env template: `deploy/.env.aws.example`
- Terraform EC2 provisioning: `infra/terraform/`

### What the pipeline does

1. On every push to `main`, builds all backend and frontend Docker images
2. Pushes them to Docker Hub with two tags:
  - short commit SHA (for immutable deploys)
  - `latest`
3. SSH into AWS EC2, pulls latest repo state, and runs:
  - `docker compose -f deploy/docker-compose.aws.yml pull`
  - `docker compose -f deploy/docker-compose.aws.yml up -d`

### GitHub repository secrets required

Add these in GitHub: `Settings -> Secrets and variables -> Actions`.

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN` (Docker Hub access token)
- `AWS_EC2_HOST` (public IP or DNS)
- `AWS_EC2_USER` (usually `ubuntu` for Ubuntu AMI, `ec2-user` for Amazon Linux)
- `AWS_EC2_SSH_KEY` (private key content)
- `AWS_EC2_PORT` (optional, default 22)
- `AWS_APP_DIR` (optional, e.g. `/home/ubuntu/careerbridge`)

### EC2 one-time setup

1. Launch an EC2 instance (Ubuntu recommended)
2. Open inbound ports in Security Group:
  - `22` (SSH)
  - `3000, 8080, 8081, 8082, 8083, 8084, 8085, 8086, 8761, 8888`
  - `3307` only if you need external DB access (otherwise keep closed)
3. Install Docker + Docker Compose plugin on EC2
4. Clone this repository on EC2 into `$AWS_APP_DIR`
5. Create deploy env file on EC2:

```bash
cd <your-app-dir>
cp deploy/.env.aws.example deploy/.env.aws
# edit deploy/.env.aws with real production values
```

6. Push to `main` to trigger deployment

### Manual deploy command on EC2

```bash
cd <your-app-dir>
export DOCKERHUB_USERNAME=<your-dockerhub-username>
export IMAGE_TAG=<short-commit-sha-or-latest>
docker compose -f deploy/docker-compose.aws.yml --env-file deploy/.env.aws pull
docker compose -f deploy/docker-compose.aws.yml --env-file deploy/.env.aws up -d
```

---

---

## Backend Architecture

### Services Overview

| Service | Port | Description |
|---------|------|-------------|
| `eureka-server` | 8761 | Netflix Eureka service registry |
| `config-server` | 8888 | Spring Cloud Config (native, reads `config-repo/`) |
| `auth-service` | 8081 | JWT auth, OTP, user management, Cloudinary profile images |
| `job-service` | 8082 | Job CRUD, search, Redis caching, Kafka events |
| `application-service` | 8083 | Applications, resume upload, status management |
| `file-service` | 8084 | Cloudinary file upload proxy |
| `notification-service` | 8085 | Email via Gmail SMTP, SSE streaming, Kafka consumer |
| `admin-service` | 8086 | Analytics dashboard, proxies to other services via Feign |
| `api-gateway` | 8080 | Spring Cloud Gateway, JWT validation, rate limiting |

### CQRS Pattern

`job-service` and `application-service` use a lightweight CQRS pattern:
- **Commands** (write): `CreateJobCommand`, `UpdateJobCommand`, `DeleteJobCommand` → `JobCommandHandler`
- **Queries** (read): `SearchJobsQuery`, `GetJobByIdQuery` → `JobQueryHandler`
- The service facade (`JobService`) is a thin orchestrator — controllers talk only to it

### Kafka Topics

| Topic | Producer | Consumer |
|-------|----------|----------|
| `user-events` | auth-service | notification-service |
| `job-events` | job-service | notification-service |
| `application-events` | application-service | notification-service |

### Running a Single Service

```bash
# From the backend/ directory, set env vars first:
export SPRING_DATASOURCE_USERNAME=careerbridge
export SPRING_DATASOURCE_PASSWORD=AppPassword!
export JWT_SECRET=your-64-char-secret
export KAFKA_BOOTSTRAP_SERVERS=localhost:9092
export REDIS_HOST=localhost

cd auth-service && mvn spring-boot:run
```

### Swagger UI

Each service exposes Swagger at `http://localhost:<port>/swagger-ui.html`  
The API Gateway aggregates them at `http://localhost:8080/swagger-ui.html`

### Database Init

MySQL databases are created automatically via `createDatabaseIfNotExist=true` in JDBC URLs.  
The `docker/mysql/init.sql` and `init.sh` pre-create all four DBs and grant permissions on first Docker run.

Default admin is seeded by `auth-service/DataSeeder.java` on startup if not already present.

---

## Frontend Architecture

### Tech Stack

React 18 + TypeScript + Vite + Redux Toolkit + TailwindCSS SPA.

### Development Setup

```bash
npm install
npm run dev        # → http://localhost:3000 with HMR
```

The Vite dev server proxies all `/api` requests to `http://localhost:8080` (API Gateway). Make sure the backend stack is running first (`./backend/start-dev.sh` or Docker).

### Build & Testing

```bash
npm run build           # TypeScript check + Vite production build → dist/
npm run preview         # Preview the production build locally
npm test                # Vitest watch mode
npm run test:coverage   # Coverage report
npm run lint            # ESLint check
```

### Key Directories

```
src/
├── core/
│   ├── api/
│   │   ├── axios.ts          # Axios instance, interceptors, token helpers
│   │   └── services/         # Per-domain API service functions
│   └── guards/
│       └── RouteGuards.tsx   # ProtectedRoute, PublicOnlyRoute
├── features/                 # Page components by domain
│   ├── auth/                 # Login, Register (multi-step + OTP)
│   ├── jobs/                 # Home, Jobs list, Job detail, Post/Edit job
│   ├── applications/         # Job seeker applications, Recruiter inbox
│   ├── dashboard/            # Role-specific dashboards
│   ├── profile/              # Profile edit, password change, avatar upload
│   └── admin/                # Admin user/job/application management
├── layouts/
│   ├── Navbar.tsx            # Sticky nav, notification bell, SSE subscription
│   ├── Footer.tsx
│   └── MainLayout.tsx
├── shared/
│   ├── components/ui/        # Button, Input, Modal, Avatar, Badge, etc.
│   ├── hooks/redux.ts        # Typed useAppDispatch / useAppSelector
│   └── utils/helpers.ts      # cn(), formatDate(), formatSalary(), etc.
└── store/
    ├── index.ts
    └── slices/               # authSlice, jobsSlice, applicationsSlice,
                              # notificationsSlice, uiSlice
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `VITE_API_BASE_URL` | `http://localhost:8080` | API Gateway base URL |
| `VITE_APP_NAME` | `CareerBridge` | App display name |
| `VITE_APP_VERSION` | `1.0.0` | App version |

Copy `.env.example` to `.env` and adjust for your environment.

### Token Storage

- **Access token**: in-memory (`_accessToken`) + `sessionStorage` (tab persistence)
- **Refresh token**: `localStorage` (survives tab close for seamless re-auth)
- **User profile**: `localStorage` (for instant initial render before API hydration)

The axios response interceptor automatically refreshes the access token on 401 and queues concurrent requests during the refresh.

### Real-Time Notifications

The `Navbar` subscribes to SSE at `/api/v1/notifications/my/stream?token=<jwt>` when the user is authenticated. On receiving a `notification` event, it re-fetches the notification list. The SSE connection is torn down on logout.

---

## Review Notes (Changes Applied)

This project was reviewed and patched. Key fixes:

1. **Created `EventDTO.java`** — Kafka consumer config referenced this class as the default deserialisation type but it did not exist, causing `ClassNotFoundException` at startup.
2. **Fixed Kafka listener type** — `config-repo/notification-service.yml` had `type: batch` but all `@KafkaListener` methods accept single objects. Changed to `type: single`.
3. **Added Kafka topic declarations** — Added `app.kafka.topics.*` entries to `notification-service/application.yml` for consistency.
4. **Fixed CRLF line endings** — Converted Windows-style line endings to Unix LF across all source files.
5. **Updated `build.sh`** — Added explicit `full` subcommand, `--profile full` propagation, and clearer URL/profile output.
6. **Added `start-dev.sh`** — New helper to spin up only infrastructure for local dev mode.

See `CHANGELOG.md` for the complete file-level change log.
