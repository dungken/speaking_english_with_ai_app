# Core Module

The `core` module is the foundation of the clean architecture implementation in this Flutter application. It contains shared utilities, services, and architectural components used across the entire application, ensuring consistency and promoting code reuse.

## Directory Structure

### 📁 constants
- **api_constants.dart**: Contains API endpoints, URLs, and related constant values used throughout the app, centralizing all API-related constants.

### 📁 di (Dependency Injection)
- **injection_container.dart**: Handles dependency injection setup using a service locator pattern, initializing and registering all dependencies.

### 📁 error
- **exceptions.dart**: Defines custom exception classes for specific error scenarios.
- **failures.dart**: Implements failure classes representing different types of business logic failures, following clean architecture principles.

### 📁 network
- **network_info.dart**: Provides network connectivity information and checks for internet connection.

### 📁 presentation
- Contains shared UI components and widgets used across different features.
- **README.md**: Documentation for the shared UI component library.
- **📁 widgets/**: Reusable UI components.

### 📁 routes
- **app_page_transitions.dart**: Defines custom page transition animations for navigation.
- **app_router.dart**: Implements the app's routing system, defining all available routes.

### 📁 services
- **audio_services.dart**: Provides audio recording, playback, and processing capabilities.
- **📁 di/**: 
  - **service_locator.dart**: Implements a service locator pattern specifically for core services.

### 📁 theme
- **app_colors.dart**: Defines the color palette and theme colors.
- **app_theme.dart**: Configures and exports the app's theme data.
- **text_styles.dart**: Defines typography styles and text themes.
- **theme_cubit.dart**: Manages the application's theme state using the Cubit pattern.
- **theme_provider.dart**: Provides the current theme to the widget tree using the Provider pattern.

### 📁 usecase / usecases
- **usecase.dart**: Defines the base interface for all use cases in the application following clean architecture principles.

## Architecture Overview

The core module follows clean architecture principles and is designed to be framework-agnostic wherever possible. This means that the business logic (use cases) and data layers are separated from the UI and external frameworks.

### Key Architecture Components

1. **Use Cases**: Represent application-specific business rules.
2. **Failures**: Used instead of exceptions for domain-level errors.
3. **Dependency Injection**: Service locator pattern for managing dependencies.
4. **Repository Pattern**: Abstracts data sources and provides a clean API to the domain layer.

## Best Practices

When working with the core module:

1. **Don't mix concerns**: Keep UI logic separate from business logic.
2. **Maintain abstraction layers**: Follow the dependency rule (dependencies point inward).
3. **Use dependency injection**: Register new components in the appropriate injection container.
4. **Error handling**: Use failures for domain errors and exceptions for infrastructure errors.
5. **Keep it clean**: The core module should only contain shared components used by multiple features.

## Usage Guidelines

- New features should be added to the `features` directory, not to the core.
- When adding shared functionality, consider if it belongs in the core or if it should be feature-specific.
- Follow the established patterns for consistency across the codebase.
- Core utilities should be well-tested and robust, as they are used across the application.

