# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a Node.js/Express API for an "acquisitions" system with JWT-based authentication. The project uses modern ES modules, Drizzle ORM with PostgreSQL (Neon database), and follows a layered architecture pattern.

## Architecture

### Tech Stack

- **Runtime**: Node.js with ES modules (`"type": "module"`)
- **Framework**: Express 5.x
- **Database**: PostgreSQL via Neon Database (@neondatabase/serverless)
- **ORM**: Drizzle ORM with Drizzle Kit for migrations
- **Authentication**: JWT tokens with bcrypt password hashing
- **Validation**: Zod schemas
- **Logging**: Winston with file and console transports
- **Security**: Helmet, CORS, cookie-parser

### Project Structure

```
src/
├── config/          # Database connection, logger configuration
├── controllers/     # Route handlers (currently auth only)
├── models/          # Drizzle ORM schema definitions
├── routes/          # Express route definitions
├── services/        # Business logic layer
├── utils/           # Helper utilities (JWT, cookies, formatting)
├── validations/     # Zod validation schemas
├── app.js          # Express app configuration
├── index.js        # Entry point (loads dotenv and server)
└── server.js       # Server startup
```

### Import Aliases

The project uses Node.js import maps for cleaner imports:

- `#config/*` → `./src/config/*`
- `#controllers/*` → `./src/controllers/*` (note: typo in package.json as `#controlllers/*`)
- `#models/*` → `./src/models/*`
- `#routes/*` → `./src/routes/*`
- `#services/*` → `./src/services/*`
- `#utils/*` → `./src/utils/*`
- `#validations/*` → `./src/validations/*`

## Development Commands

### Basic Development

```bash
npm run dev              # Start development server with --watch flag
```

### Code Quality

```bash
npm run lint             # Run ESLint
npm run lint:fix         # Fix ESLint issues automatically
npm run format           # Format code with Prettier
npm run format:check     # Check if code is properly formatted
```

### Database Operations

```bash
npm run db:generate      # Generate Drizzle migrations from schema changes
npm run db:migrate       # Apply migrations to database
npm run db:studio        # Launch Drizzle Studio (database GUI)
```

## Database Architecture

- **ORM**: Drizzle ORM with PostgreSQL dialect
- **Connection**: Neon Database serverless driver
- **Schema Location**: `src/models/*.js`
- **Migrations**: Generated in `drizzle/` directory
- **Configuration**: `drizzle.config.js`

### Current Schema

- `users` table: id, name, email, password (hashed), role, timestamps

## Authentication System

- **JWT Strategy**: Tokens stored in HTTP-only cookies
- **Password Hashing**: bcrypt with 10 salt rounds
- **Cookie Security**: httpOnly, secure in production, sameSite: strict, 15min expiry
- **Roles**: 'user' (default) and 'admin'

### Auth Flow

1. Request validation with Zod schemas (`src/validations/auth.validation.js`)
2. Service layer handles business logic (`src/services/auth.service.js`)
3. JWT token generation and cookie setting (`src/utils/jwt.js`, `src/utils/cookies.js`)
4. Structured error responses with validation formatting

## Environment Variables

Copy `.env.example` to `.env` and configure:

```
PORT=3000
NODE_ENV=development
LOG_LEVEL=info
DATABASE_URL=your_neon_database_url
JWT_SECRET=your_jwt_secret_key
```

## Code Standards

### ESLint Rules (eslint.config.js)

- ES2022 syntax with modules
- 2-space indentation with switch case indentation
- Single quotes, semicolons required
- Unix line endings
- Arrow functions preferred
- No unused variables (except `_` prefixed)

### Prettier Configuration

- Single quotes, semicolons
- 2-space tabs, 80 character line width
- ES5 trailing commas
- Arrow parens avoided where possible

## Logging

Winston logger configured with:

- **Development**: Console output with colors + file logging
- **Production**: File logging only
- **Files**: `logs/error.log` (errors), `logs/combined.log` (all)
- **Format**: JSON with timestamps and error stack traces
- **Service**: Tagged as 'acquisitions-api'

## API Endpoints

### Health/Status

- `GET /` - Basic API greeting
- `GET /health` - Health check with uptime
- `GET /api` - API status message

### Authentication (under /api/auth)

- `POST /api/auth/sign-up` - User registration (implemented)
- `POST /api/auth/sign-in` - User login (placeholder)
- `POST /api/auth/sign-out` - User logout (placeholder)

## Development Notes

### Known Issues

- Typo in package.json import alias: `#controlllers/*` (extra 'l')
- Auth service has bug in user existence check (missing await)
- Sign-in and sign-out routes are not implemented

### Extending the API

1. Add new models in `src/models/`
2. Run `npm run db:generate` to create migrations
3. Create services for business logic
4. Add Zod validation schemas
5. Implement controllers with proper error handling
6. Define routes and mount in `src/app.js`
7. Use the established import alias pattern

### Testing Database Changes

Use `npm run db:studio` to visually inspect database schema and data during development.
