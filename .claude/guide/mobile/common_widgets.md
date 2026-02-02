# Common Flutter Widgets to Use

## Layout Widgets
- `Column`, `Row` - Vertical/horizontal layouts
- `Stack` - Overlapping widgets
- `Container` - Box model with padding, margin, decoration
- `SizedBox` - Fixed size spacing
- `Expanded`, `Flexible` - Flexible sizing in Column/Row
- `ListView`, `GridView` - Scrollable lists
- `SingleChildScrollView` - Make content scrollable

## Material Widgets
- `Scaffold` - Basic app structure with AppBar, Drawer, BottomNavigationBar
- `AppBar` - Top app bar
- `Card` - Material card with elevation
- `ElevatedButton`, `TextButton`, `OutlinedButton` - Buttons
- `TextField` - Text input
- `Dialog`, `BottomSheet` - Modal overlays

## GetX Widgets
- `GetMaterialApp` - Root app widget (replaces MaterialApp)
- `GetView<Controller>` - Stateless widget with auto-injected controller
- `GetWidget<Controller>` - Like GetView but controller persists
- `Obx()` - Reactive widget that rebuilds on .obs changes
- `GetBuilder<Controller>()` - Manual rebuild control with update()
- `GetX<Controller>()` - Combines dependency injection and reactivity
