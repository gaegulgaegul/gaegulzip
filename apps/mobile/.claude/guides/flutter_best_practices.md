# Flutter Best Practices

## Widget Development
- **Use `const` constructors** wherever possible to improve performance
- **Keep widgets small and focused** - extract complex widgets into separate classes
- **Prefer composition over inheritance** - combine simple widgets rather than creating deep hierarchies
- **Use `Key` properly** when widget identity matters (lists, animations)
- **Extract repeated code** into reusable widgets or methods

## State Management
- **Keep UI and business logic separate** - controllers handle logic, views display data
- **Minimize rebuilds** - use specific reactive widgets (Obx, GetBuilder) instead of rebuilding entire screens
- **Dispose resources properly** - use GetX lifecycle methods (onClose, onInit)

## Performance
- **Avoid unnecessary rebuilds** - use `const` widgets and memoization
- **Use ListView.builder** for long lists instead of ListView with all children
- **Optimize image loading** - use appropriate image resolutions and caching
- **Profile before optimizing** - use Flutter DevTools to identify actual bottlenecks

## Code Organization
- **One widget per file** for major screens/components
- **Group related files** by feature, not by type
- **Use barrel files** (re-export files) for cleaner imports
- **Keep files under 300 lines** - split larger files

## Platform-Specific Code
- **Handle platform differences gracefully** using Platform checks or conditional imports
- **Test on all target platforms** before releasing
- **Use platform channels** only when necessary
