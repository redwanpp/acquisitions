#!/bin/bash

# Development startup script for Acquisition App with Neon Local
# This script starts the application in development mode with Neon Local

echo "🚀 Starting Acquisition App in Development Mode"
echo "================================================"

# Check if .env.development exists
if [ ! -f .env.development ]; then
    echo "❌ Error: .env.development file not found!"
    echo "   Creating .env.development from template..."
    
    cat > .env.development << 'EOF'
# Development Environment Configuration
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug

# Neon Local Database Configuration
DATABASE_URL=postgres://neon:npg@neon-local:5432/acquisitions?sslmode=require

# Neon API Configuration (REQUIRED - Get these from Neon Console)
NEON_API_KEY=your_neon_api_key_here
NEON_PROJECT_ID=your_neon_project_id_here
PARENT_BRANCH_ID=your_main_branch_id_here
EOF

    echo "✅ Created .env.development template"
    echo "❗ IMPORTANT: Please update .env.development with your actual Neon credentials before continuing!"
    echo "   Get these from: https://console.neon.tech"
    echo ""
    read -p "Press Enter when you've updated the credentials, or Ctrl+C to exit..."
fi

# Validate credentials are not placeholders
if grep -q "your_.*_here" .env.development 2>/dev/null; then
    echo "❌ Error: .env.development still contains placeholder values!"
    echo "   Please update NEON_API_KEY, NEON_PROJECT_ID, and PARENT_BRANCH_ID with actual values."
    exit 1
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Error: Docker is not running!"
    echo "   Please start Docker and try again."
    exit 1
fi

# Create .neon_local directory if it doesn't exist
mkdir -p .neon_local

# Add .neon_local to .gitignore if not already present
if ! grep -q ".neon_local/" .gitignore 2>/dev/null; then
    echo ".neon_local/" >> .gitignore
    echo "✅ Added .neon_local/ to .gitignore"
fi

# Stop any existing containers
echo "🧹 Stopping any existing containers..."
docker compose -f docker-compose.dev.yml down --remove-orphans 2>/dev/null || true

echo "📦 Building and starting development containers..."
echo "   - Neon Local proxy will create an ephemeral database branch"
echo "   - Application will run on http://localhost:3000"
echo ""

# Start development environment
echo "⏳ Starting services (this may take a moment)..."
docker compose -f docker-compose.dev.yml up --build -d

# Wait for Neon Local to be healthy
echo "⏳ Waiting for Neon Local to be ready..."
for i in {1..30}; do
    if docker compose -f docker-compose.dev.yml exec neon-local pg_isready -h localhost -U neon >/dev/null 2>&1; then
        echo "✅ Neon Local is ready!"
        break
    fi
    echo "   Attempt $i/30..."
    sleep 2
done

# Wait for the application to be ready
echo "⏳ Waiting for application to be ready..."
for i in {1..30}; do
    if curl -f http://localhost:3000/health >/dev/null 2>&1; then
        echo "✅ Application is ready!"
        break
    fi
    echo "   Attempt $i/30..."
    sleep 2
done

# Run migrations with Drizzle (now that everything is up)
echo "📜 Applying latest schema with Drizzle..."
docker compose -f docker-compose.dev.yml exec app npm run db:migrate

# Show logs to help with debugging
echo "📋 Recent application logs:"
docker compose -f docker-compose.dev.yml logs --tail=10 app

echo ""
echo "🎉 Development environment started successfully!"
echo "================================================"
echo "   🌐 Application: http://localhost:3000"
echo "   🏥 Health Check: http://localhost:3000/health"
echo "   🗄️  Database: postgres://neon:npg@localhost:5432/acquisitions"
echo "   📊 Neon Local: Running with ephemeral branch"
echo ""
echo "📋 Useful commands:"
echo "   View logs:           docker compose -f docker-compose.dev.yml logs -f"
echo "   View app logs:       docker compose -f docker-compose.dev.yml logs -f app"
echo "   View database logs:  docker compose -f docker-compose.dev.yml logs -f neon-local"
echo "   Stop services:       docker compose -f docker-compose.dev.yml down"
echo "   Restart services:    ./setup-docker.sh dev"
echo ""
echo "🔄 To get a fresh database, restart the containers:"
echo "   docker compose -f docker-compose.dev.yml down && ./start-dev-fixed.sh"