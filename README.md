# Acquisitions API

A Node.js Express application for managing acquisitions, dockerized with support for both development (Neon Local) and production (Neon Cloud) environments.

## Architecture

- **Development**: Uses Neon Local proxy via Docker for ephemeral database branches
- **Production**: Connects directly to Neon Cloud database
- **Database**: PostgreSQL via Neon Database with Drizzle ORM
- **Framework**: Express.js with modern ES6 modules

## Prerequisites

- Docker and Docker Compose
- Node.js 20+ (for local development without Docker)
- Neon Database account and project

## Getting Started

### 1. Clone and Setup

```bash
git clone <repository-url>
cd acquisitions
chmod +x setup-docker.sh  # Make setup script executable
```

### 2. Get Neon Database Credentials

1. Go to [Neon Console](https://console.neon.tech)
2. Create or select your project
3. Get the following credentials:
   - **NEON_API_KEY**: From Account Settings > API Keys
   - **NEON_PROJECT_ID**: From Project Settings > General
   - **PARENT_BRANCH_ID**: Usually your main/default branch ID

## 🚀 Quick Start with Setup Script

The project includes a comprehensive setup script that handles all Docker operations:

```bash
# Show all available commands
./setup-docker.sh help

# Start development environment (creates environment file if needed)
./setup-docker.sh dev

# Start production environment
./setup-docker.sh prod

# Show service status
./setup-docker.sh status

# View logs
./setup-docker.sh logs dev

# Run database migrations
./setup-docker.sh migrate dev

# Stop all services
./setup-docker.sh stop all

# Clean up Docker resources
./setup-docker.sh clean
```

### Using Make (Alternative)

```bash
# Show available targets
make help

# Start development
make dev

# Start production
make prod

# View logs
make logs

# Stop services
make stop
```

## Development Setup (with Neon Local)

### Environment Configuration

1. Copy the development environment template:
```bash
cp .env.development.template .env.development
```

2. Update `.env.development` with your Neon credentials:
```env
# Development Environment Configuration
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug

# Neon Local Database Configuration
DATABASE_URL=postgres://neon:npg@neon-local:5432/acquisitions?sslmode=require

# Neon API Configuration
NEON_API_KEY=your_actual_neon_api_key
NEON_PROJECT_ID=your_actual_project_id
PARENT_BRANCH_ID=your_main_branch_id
```

### Start Development Environment

Using the setup script (recommended):
```bash
# Start development environment
./setup-docker.sh dev

# Or start in detached mode
./setup-docker.sh dev --detached

# Using make (if you prefer)
make dev
```

Or manually with Docker Compose:
```bash
# Start with Neon Local (creates ephemeral database branch)
docker-compose -f docker-compose.dev.yml up --build

# Or start in detached mode
docker-compose -f docker-compose.dev.yml up -d --build
```

This will:
- Start Neon Local proxy on port 5432
- Create an ephemeral database branch automatically
- Start your application on http://localhost:3000
- Enable hot reloading for development

### Run Database Migrations

```bash
# Run migrations against the development database
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Generate new migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:generate

# Open Drizzle Studio
docker-compose -f docker-compose.dev.yml exec app npm run db:studio
```

### Development Workflow

1. **Code Changes**: Edit files in `src/` - changes will be reflected immediately
2. **Database Schema**: Modify models in `src/models/`, then run `npm run db:generate` and `npm run db:migrate`
3. **Fresh Database**: Restart the container to get a fresh ephemeral branch

```bash
# Restart to get fresh database
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.dev.yml up
```

## Production Deployment

### Environment Configuration

1. Create production environment file:
```bash
cp .env.production.template .env.production
```

2. Update `.env.production` with your production Neon Cloud URL:
```env
# Production Environment Configuration
NODE_ENV=production
PORT=3000
LOG_LEVEL=info

# Neon Cloud Database Configuration
DATABASE_URL=postgres://username:password@ep-example-123.us-east-1.postgres.neon.tech/dbname?sslmode=require
```

### Deploy to Production

```bash
# Build and start production containers
docker-compose -f docker-compose.prod.yml up -d --build

# With nginx reverse proxy (optional)
docker-compose -f docker-compose.prod.yml --profile nginx up -d --build
```

### Production Environment Variables

For security, inject the `DATABASE_URL` via environment variables instead of the `.env.production` file:

```bash
# Example with environment variable
DATABASE_URL="your_production_neon_url" docker-compose -f docker-compose.prod.yml up -d
```

### Production Health Checks

The application includes health checks accessible at:
- http://localhost:3000/health

## Database Schema Management

### Using Drizzle ORM

```bash
# Generate migration files
npm run db:generate

# Apply migrations
npm run db:migrate

# Open Drizzle Studio (database explorer)
npm run db:studio
```

### Direct Database Access

#### Development (via Neon Local)
```bash
# Connect to the development database
docker-compose -f docker-compose.dev.yml exec neon-local psql -h localhost -U neon -d acquisitions
```

#### Production (via Neon Cloud)
```bash
# Use your production DATABASE_URL with psql
psql "postgres://username:password@ep-example-123.us-east-1.postgres.neon.tech/dbname?sslmode=require"
```

## API Endpoints

- **GET /**: Welcome message
- **GET /health**: Application health check
- **GET /api**: API status
- **POST /api/auth/***: Authentication routes

## Monitoring and Logs

### View Logs

```bash
# Development logs
docker-compose -f docker-compose.dev.yml logs -f app

# Production logs
docker-compose -f docker-compose.prod.yml logs -f app

# Neon Local logs
docker-compose -f docker-compose.dev.yml logs -f neon-local
```

### Log Files

Logs are also written to `./logs/` directory:
- `combined.log`: All log levels
- `error.log`: Error logs only

## Troubleshooting

### Development Issues

**Neon Local won't start:**
```bash
# Check if your credentials are correct
docker-compose -f docker-compose.dev.yml logs neon-local

# Verify environment variables
docker-compose -f docker-compose.dev.yml config
```

**Application can't connect to database:**
```bash
# Check if Neon Local is healthy
docker-compose -f docker-compose.dev.yml ps

# Test database connection
docker-compose -f docker-compose.dev.yml exec neon-local pg_isready -h localhost -U neon
```

**Fresh database needed:**
```bash
# Restart containers (creates new ephemeral branch)
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.dev.yml up
```

### Production Issues

**Database connection errors:**
- Verify `DATABASE_URL` is correct
- Check network connectivity to Neon Cloud
- Ensure SSL mode is properly configured

**Performance issues:**
- Monitor database performance in Neon Console
- Check application logs for slow queries
- Consider connection pooling settings

## Environment Comparison

| Feature | Development | Production |
|---------|-------------|------------|
| Database | Neon Local (Ephemeral) | Neon Cloud (Persistent) |
| SSL | Self-signed cert | Production cert |
| Logging | Debug level | Info level |
| Hot Reload | Enabled | Disabled |
| Health Checks | Basic | Enhanced |
| Resource Limits | None | CPU/Memory limits |

## Security Considerations

- Environment files with secrets are gitignored
- Production uses resource limits and non-root user
- SSL enforced for all database connections
- Secrets should be injected via environment variables in production

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test locally with `docker-compose.dev.yml`
4. Ensure linting and formatting pass: `npm run lint && npm run format`
5. Submit a pull request

## Scripts

```bash
npm run dev          # Start development server (non-Docker)
npm run lint         # Run ESLint
npm run lint:fix     # Fix ESLint issues
npm run format       # Format code with Prettier
npm run format:check # Check code formatting
npm run db:generate  # Generate Drizzle migrations
npm run db:migrate   # Apply database migrations
npm run db:studio    # Open Drizzle Studio
```

## Docker Commands Reference

```bash
# Development
docker-compose -f docker-compose.dev.yml up --build    # Start dev environment
docker-compose -f docker-compose.dev.yml down          # Stop dev environment
docker-compose -f docker-compose.dev.yml logs -f       # View logs

# Production  
docker-compose -f docker-compose.prod.yml up -d --build    # Start prod environment
docker-compose -f docker-compose.prod.yml down             # Stop prod environment
docker-compose -f docker-compose.prod.yml logs -f          # View logs

# Utility
docker-compose -f docker-compose.dev.yml exec app sh       # Shell into app container
docker-compose -f docker-compose.dev.yml ps                # View container status
```

---

## License

ISC