# Recommended Directory Structure

## For `apps/wowa` (GetX-based architecture)
```
lib/
├── app/
│   ├── modules/              # Feature modules
│   │   ├── home/
│   │   │   ├── controllers/  # GetX controllers
│   │   │   │   └── home_controller.dart
│   │   │   ├── views/        # UI screens
│   │   │   │   └── home_view.dart
│   │   │   └── bindings/     # Dependency injection
│   │   │       └── home_binding.dart
│   │   ├── profile/
│   │   └── settings/
│   ├── routes/
│   │   ├── app_pages.dart    # Route definitions
│   │   └── app_routes.dart   # Route names
│   └── data/
│       ├── models/           # Local models (different from API models)
│       ├── providers/        # API call wrappers
│       └── repositories/     # Data access layer
├── core/
│   ├── utils/                # Utility functions
│   ├── values/
│   │   ├── colors.dart
│   │   ├── strings.dart
│   │   └── dimensions.dart
│   ├── theme/                # App theme
│   └── widgets/              # Shared widgets
└── main.dart
```

## For `packages/api`
```
lib/
├── src/
│   ├── models/               # API response/request models
│   │   └── *.freezed.dart   # Generated files
│   ├── clients/              # Dio clients
│   │   └── api_client.dart
│   ├── interceptors/         # HTTP interceptors
│   └── endpoints/            # API endpoint constants
└── api.dart                  # Public exports
```

## For `packages/design_system`
```
lib/
├── src/
│   ├── components/           # Reusable UI components
│   │   ├── buttons/
│   │   ├── cards/
│   │   └── inputs/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── app_theme.dart
│   └── constants/            # Design constants
└── design_system.dart        # Public exports
```

## For `packages/core`
```
lib/
├── src/
│   ├── utils/                # Utilities
│   │   ├── logger.dart
│   │   ├── date_utils.dart
│   │   └── validators.dart
│   ├── extensions/           # Dart extensions
│   │   ├── string_extensions.dart
│   │   └── datetime_extensions.dart
│   ├── constants/            # App-wide constants
│   └── errors/               # Error handling
│       └── exceptions.dart
└── core.dart                 # Public exports
```
