# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

gaegulzip is a hybrid monorepo containing both a TypeScript/Express backend server and a Flutter mobile application with shared packages. The repository combines pnpm workspaces (for Node.js) and Melos (for Flutter) to manage dependencies and scripts.

## Monorepo Structure

```
gaegulzip/
├── apps/
│   ├── server/              # TypeScript/Express backend (Node.js)
│   └── mobile/              # Flutter monorepo (managed by Melos)
│       ├── apps/wowa/       # Main Flutter application
│       └── packages/        # Shared Flutter packages
│           ├── core/        # Foundation utilities, DI, logging
│           ├── api/         # HTTP client, data models
│           └── design_system/ # UI components, theme
├── packages/                # (Reserved for shared packages if needed)
├── turbo.json              # Turborepo task configuration
├── pnpm-workspace.yaml     # pnpm workspace definition
└── melos.yaml              # Melos configuration for Flutter packages
```

## Essential Commands

### Monorepo Management

```bash
# Install all dependencies (Node.js workspaces)
pnpm install

# Run development servers (uses Turborepo)
pnpm dev                    # Runs all dev tasks in parallel

# Build all projects
pnpm build                  # Runs all build tasks
```

### Server (apps/server)

```bash
cd apps/server

# Development (with hot reload)
pnpm dev

# Build for production
pnpm build

# Run production build
pnpm start

# Database migrations (Drizzle ORM)
pnpm drizzle-kit generate   # Generate migration files
pnpm drizzle-kit migrate    # Apply migrations
pnpm drizzle-kit push       # Push schema changes (dev only)

# Run tests (unit tests only)
pnpm test                   # Run all unit tests
pnpm test:watch             # Watch mode
```

### Mobile (apps/mobile)

```bash
cd apps/mobile

# Initial setup (ALWAYS use this instead of flutter pub get)
melos bootstrap

# Clean all build artifacts
melos clean

# Full reset
melos clean && melos bootstrap

# Code generation (for api package models)
melos generate              # One-time generation
melos generate:watch        # Watch mode during development

# Quality checks
melos analyze               # Analyze all packages
melos format                # Format all Dart files
melos outdated              # Check for outdated dependencies

# Run wowa app
cd apps/wowa
flutter run                 # Default device
flutter run -d chrome       # Web
flutter run -d macos        # macOS
flutter run -d ios          # iOS simulator
```

## Architecture Principles

### Server Architecture (apps/server)

**Tech Stack:**
- Runtime: Node.js with TypeScript (ES2022)
- Framework: Express 5.x (middleware-based, minimal)
- ORM: Drizzle ORM
- Database: PostgreSQL (Supabase)
- Testing: Vitest (unit tests only)

**Project Structure:**
```
src/
├── config/                 # Configuration (db, env)
├── modules/                # Feature-based modules
│   └── [feature]/
│       ├── index.ts              # Router export
│       ├── handlers.ts           # Request handlers (middleware functions)
│       ├── schema.ts             # Drizzle schema
│       └── middleware.ts         # Feature-specific middleware (optional)
├── middleware/             # Shared Express middleware
├── utils/                  # Shared utilities
├── app.ts                  # Express app setup
└── server.ts               # Entry point
```

**Key Conventions:**
- Handlers are middleware functions `(req, res, next) => {}`
- No Controller/Service pattern (NestJS style) - keep it minimal
- Business logic stays in handlers unless complexity demands separation (YAGNI)
- Error handling: Use global error handler middleware, throw custom AppError classes

**Detailed guides:** See `apps/server/CLAUDE.md` for comprehensive server-specific conventions including:
- Exception handling patterns
- API response design (null handling, naming, data types)
- Drizzle ORM conventions (no FK constraints, comment requirements)
- Logging best practices (Domain Probe pattern)
- Code documentation standards

### Mobile Architecture (apps/mobile)

**Tech Stack:**
- Framework: Flutter
- Monorepo: Melos
- State Management: GetX
- HTTP Client: Dio (isolated to api package)
- Code Generation: Freezed, json_serializable, build_runner

**Layered Package Architecture:**
```
core (foundation - no internal dependencies)
  ↑
  ├── api (HTTP client, data models, serialization)
  ├── design_system (UI components, theme, reactive widgets)
  └── wowa app (integrates all packages, app logic, routing)
```

**Key Principles:**
- `core` is the foundation with no dependencies on other internal packages
- All packages depend on `core`
- The app depends on all packages
- No circular dependencies - dependency flow is one-way up
- GetX is shared across core, design_system, and wowa for consistent state management
- Dio is isolated to api package to centralize HTTP logic

**Detailed guides:** See `apps/mobile/CLAUDE.md` for comprehensive mobile-specific conventions including:
- Flutter best practices (const constructors, widget size, performance)
- GetX best practices (controllers, bindings, navigation, reactive programming)
- Design System (Frame0 sketch style, 12 UI components, CustomPainter)
- Directory structure recommendations
- Common patterns and widgets
- Error handling in controllers and views

## Testing Policy

- **Server (apps/server)**: Unit tests required, focus on handlers and utilities
- **Mobile (apps/mobile)**: **DO NOT write test code** - tests are not required for features or bug fixes

## Development Workflow

### Adding Dependencies

**For Server (Node.js):**
```bash
cd apps/server
pnpm add <package>          # Production dependency
pnpm add -D <package>       # Dev dependency
```

**For Mobile (Flutter):**
1. Determine correct package based on dependency graph
2. Add to appropriate `pubspec.yaml`:
   - Network/HTTP → `packages/api`
   - State management utilities → `packages/core`
   - UI-related → `packages/design_system`
   - App-specific → `apps/wowa`
3. Run `melos bootstrap` from `apps/mobile`
4. If adding code generation tools, run `melos generate`

### Working with API Models (Mobile)

When creating new API models in `apps/mobile/packages/api`:
1. Create model with Freezed and json_serializable annotations
2. Run `melos generate:watch` (leave it running)
3. Generated `.g.dart` and `.freezed.dart` files will auto-update

### Code Generation

- **Server**: Not applicable
- **Mobile**: Run `melos generate` or `melos generate:watch` for Freezed/json_serializable code generation

## Environment Variables

### Server
Required in `apps/server/.env`:
- `PORT` - Server port (default: 3001)
- `DATABASE_URL` - PostgreSQL connection string

### Mobile
Configure as needed in Flutter environment files

## Turborepo Tasks

Defined in `turbo.json`:
- `dev`: Runs development servers (cache disabled, persistent)
- `dev:server`: Server-specific dev task
- `dev:mobile`: Mobile-specific dev task (cache disabled)
- `build`: Builds all projects

## Common Issues

### Server
- See `apps/server/CLAUDE.md` for server-specific troubleshooting

### Mobile
- **Bootstrap fails**: Remove any `resolution: workspace` from pubspec.yaml, run `melos clean && melos bootstrap`
- **Code generation not working**: Ensure `build_runner` is in dev_dependencies, delete generated files and run `melos generate`
- **Import errors**: Verify package dependency in pubspec.yaml, run `melos bootstrap`
- **GetX controller not found**: Ensure binding is registered, use `Get.lazyPut()` in binding
- **Obx not updating**: Ensure variable is `.obs`, access with `.value` in controller, don't wrap in const widget

## Important Notes

- **Always use workspace-aware commands**: `pnpm install` for Node.js, `melos bootstrap` for Flutter
- **Never add `resolution: workspace`** to pubspec.yaml files (causes bootstrap failures)
- **Code generation** is only configured for packages with `build_runner` dependency (currently `api` and `wowa`)
- **Use path dependencies** for internal packages in Flutter
- **Avoid over-engineering**: Make only necessary changes, don't add features beyond what's requested
- **No backwards-compatibility hacks**: Delete unused code completely instead of renaming or commenting

## Documentation References

For detailed conventions, patterns, and best practices:
- **Server**: `apps/server/CLAUDE.md` and guides in `apps/server/.claude/guide/`
- **Mobile**: `apps/mobile/CLAUDE.md` and guides in `apps/mobile/.claude/guides/`
