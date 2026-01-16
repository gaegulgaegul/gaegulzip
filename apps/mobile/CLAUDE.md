# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter monorepo managed by Melos, containing a weather and budget tracking application (`wowa`) with shared packages for API communication, core utilities, and design system components.

## Monorepo Architecture

The codebase follows a layered package architecture:

```
core (foundation layer - no dependencies on other packages)
  ↑
  ├── api (HTTP client, data models, serialization)
  ├── design_system (UI components, reactive widgets)
  └── wowa app (integrates all packages, app logic, routing)
```

**Key principle**: `core` is the foundation and has no internal dependencies. All other packages depend on `core`. The app depends on all packages.

### Package Responsibilities

- **`packages/core`**: Foundation utilities, dependency injection (GetX), logging, shared extensions, error handling
- **`packages/api`**: HTTP communication via Dio, API response models, JSON serialization (using Freezed/json_serializable)
- **`packages/design_system`**: Reusable UI components, theme, reactive widgets using GetX
- **`apps/wowa`**: Main application, state management, routing, feature implementation

## Best Practices & Guides

**📖 Detailed guides are available in `.claude/guides/`:**

- **[Flutter Best Practices](./.claude/guides/flutter_best_practices.md)** - Widget development, state management, performance, code organization
- **[GetX Best Practices](./.claude/guides/getx_best_practices.md)** - Controllers, bindings, navigation, reactive programming, dependency injection
- **[Directory Structure](./.claude/guides/directory_structure.md)** - Recommended folder organization for all packages
- **[Common Patterns](./.claude/guides/common_patterns.md)** - Controller-View-Binding patterns, routing, API integration, responsive design
- **[Common Widgets](./.claude/guides/common_widgets.md)** - Layout, Material, and GetX widgets reference
- **[Design System](./.claude/guides/design_system.md)** - Frame0 스케치 스타일 디자인 시스템, 12개 UI 컴포넌트, CustomPainter, 테마, 컬러 팔레트
- **[Error Handling](./.claude/guides/error_handling.md)** - Error handling patterns in controllers and views
- **[Performance Optimization](./.claude/guides/performance.md)** - Const constructors, Obx scope, GetBuilder usage
- **[Comments and Documentation](./.claude/guides/comments.md)** - Documentation comments, inline comments, when and how to write effective comments

### Quick Reference

**Flutter Best Practices:**
- Use `const` constructors wherever possible
- Keep widgets small and focused
- Minimize rebuilds with specific reactive widgets
- Profile before optimizing

**GetX Best Practices:**
- One controller per screen/feature
- Use bindings for dependency injection
- Use named routes for navigation
- Choose the right reactive widget (Obx, GetBuilder, GetX)

**Design System Best Practices:**
- Use `SketchContainer`, `SketchButton`, `SketchCard` etc. for Frame0 스타일
- Wrap app with `SketchThemeExtension` in ThemeData
- Use `SketchDesignTokens` constants for spacing, colors, typography
- Customize with `roughness`, `strokeWidth`, `seed` parameters
- See `.claude/guides/design_system.md` for complete component catalog

**Comments Best Practices:**
- **모든 주석은 한글로 작성** - 문서화/구현 주석 모두 해당
- Use `///` for documentation comments on public APIs
- Use `//` for implementation comments explaining complex logic
- Explain WHY, not WHAT - code shows what happens
- **기술 용어는 영어 유지** - API, JSON, HTTP 등
- Avoid commenting obvious code - prefer self-documenting names

## Testing Policy

**IMPORTANT: Do NOT write test code in this project.**

- Tests are not required for features or bug fixes
- Existing test files should not be modified unless explicitly requested
- Focus on implementation code only

## Essential Commands

### Setup and Dependencies
```bash
# Initial setup - always use this instead of flutter pub get
melos bootstrap

# Clean all build artifacts
melos clean

# Full reset
melos clean && melos bootstrap
```

### Code Generation
```bash
# Generate code for packages with build_runner (api package)
melos generate

# Watch mode during development (keeps running, regenerates on file changes)
melos generate:watch
```

### Quality Checks
```bash
# Analyze all packages
melos analyze

# Format all Dart files
melos format

# Check for outdated dependencies
melos outdated
```

### Running the App
```bash
# Run wowa app
cd apps/wowa
flutter run

# Or with device specification
flutter run -d chrome  # Web
flutter run -d macos   # macOS
flutter run -d ios     # iOS simulator
```

### Testing (Not Required)
**Note: Test code is NOT written in this project. The commands below are for reference only.**

```bash
# Run tests in a specific package (if needed)
cd packages/core && flutter test
cd packages/api && flutter test
cd packages/design_system && flutter test
cd apps/wowa && flutter test

# Note: melos test may fail if run from root, use package-specific commands
```

## Development Workflow

### Adding New Dependencies

1. **Determine the correct package** based on the dependency graph
2. **Add to appropriate pubspec.yaml**:
   - Network/HTTP → `packages/api`
   - State management utilities → `packages/core`
   - UI-related → `packages/design_system`
   - App-specific → `apps/wowa`
3. **Run** `melos bootstrap` to install
4. **If adding code generation tools**, add to `dev_dependencies` and run `melos generate`

### Working with API Models

When creating new API models in `packages/api`:

1. Create model with Freezed and json_serializable annotations
2. Run `melos generate:watch` in a terminal (leave it running)
3. Generated `.g.dart` and `.freezed.dart` files will auto-update

Example model structure:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_model.freezed.dart';
part 'my_model.g.dart';

@freezed
class MyModel with _$MyModel {
  factory MyModel({required String id}) = _MyModel;
  factory MyModel.fromJson(Map<String, dynamic> json) => _$MyModelFromJson(json);
}
```

### Package Inter-Dependencies

Always use path dependencies for internal packages:

```yaml
dependencies:
  core:
    path: ../core  # or ../../packages/core from app
  api:
    path: ../../packages/api  # from app
```

Never add circular dependencies. The dependency flow is one-way up the architecture.

## Key Technologies

- **Melos**: Monorepo management tool
- **GetX**: State management, dependency injection, routing (in core, design_system, wowa)
- **Dio**: HTTP client (in api package only)
- **Freezed**: Immutable data classes (in api package)
- **json_serializable**: JSON serialization (in api package)
- **build_runner**: Code generation tool

## Important Notes

- **Always use `melos bootstrap`** instead of `flutter pub get` to ensure workspace consistency
- **Never add `resolution: workspace`** to pubspec.yaml files (causes bootstrap failures)
- **Code generation is only configured** for packages with `build_runner` dependency (currently `api` and `wowa`)
- **GetX is shared** across core, design_system, and wowa for consistent state management
- **Dio is isolated** to the api package to centralize HTTP logic

## Troubleshooting

### Bootstrap fails
- Remove any `resolution: workspace` lines from pubspec.yaml files
- Run `melos clean && melos bootstrap`

### Code generation not working
- Ensure package has `build_runner` in dev_dependencies
- Run `melos generate` explicitly
- Check for syntax errors in model files
- Delete generated files and regenerate: `melos generate`

### Import errors
- Verify the package dependency is declared in pubspec.yaml
- Run `melos bootstrap` after adding dependencies
- Check the dependency graph - ensure no circular dependencies

### GetX controller not found
- Ensure binding is registered in route
- Use `Get.lazyPut()` in binding
- Check if controller is disposed prematurely
- Use `Get.find<Controller>()` to verify injection

### Hot reload issues
- Restart app if GetX bindings change
- Use `flutter clean` if state becomes inconsistent
- Check that controllers properly implement onClose()

### Obx not updating
- Ensure variable is `.obs` (e.g., `final count = 0.obs`)
- Access with `.value` in controller (e.g., `count.value++`)
- Don't wrap `.obs` variable access in Obx (just read directly)
- Check if Obx is inside a const widget (won't rebuild)
