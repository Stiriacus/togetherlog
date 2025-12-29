# Feature Request: Enhanced Rotation Controls for Page Editor

## Overview
Replace or supplement the current rotation handle with dedicated rotation controls that are easier to use, especially on small screens and touch devices.

## Problem Statement
The current `bounding_box` package rotation handle requires users to drag far away from the image to achieve rotation. Even with an 8x sensitivity multiplier, the rotation interaction is cumbersome:
- Users must move their mouse/finger far from the image center
- The circular drag motion is unintuitive for precise rotation
- Small screens make it difficult to drag far enough
- Touch screens suffer from the same issue

## Proposed Solution

### Option A: Rotation Slider (Recommended)
Add a dedicated rotation control panel that appears when an item is selected.

**UI Components:**
1. **Rotation Slider**
   - Horizontal slider for smooth rotation (-180° to +180°)
   - Shows current rotation value in degrees
   - Positioned below or beside the toolbar when item is selected

2. **Quick Rotation Buttons**
   - +15° button
   - -15° button
   - Reset to 0° button
   - 90° clockwise / counter-clockwise buttons

3. **Fine Control**
   - Text input field for precise degree entry
   - Arrow up/down keys for 1° increments

**Example UI Layout:**
```
┌─────────────────────────────────────┐
│ Selected Item Controls              │
├─────────────────────────────────────┤
│ Rotation: [-180°]━━━●━━━[+180°]     │
│           Current: 45°               │
│                                      │
│ [↺ -90°] [-15°] [0°] [+15°] [↻ +90°]│
│                                      │
│ Precise: [  45  ]° [↑] [↓]          │
└─────────────────────────────────────┘
```

### Option B: Circular Rotation Wheel
A circular dial/wheel control that appears near the selected item.

**Features:**
- Visual circular slider (like a knob)
- Drag around the circle to rotate
- Shows rotation angle in center
- Smaller radius than current handle (closer to image)

### Option C: Contextual Rotation Controls
Mini toolbar that floats near the selected item.

**Features:**
- Small popup with +/- rotation buttons
- Appears next to the selected item
- Doesn't obscure the image
- Quick +5°/-5° increments

## Implementation Details

### Recommended Approach (Option A)

#### 1. New Widget: `RotationControlPanel`
```dart
class RotationControlPanel extends ConsumerWidget {
  final String itemId;
  final String entryId;
  final double currentRotation;

  // Shows slider + buttons when item is selected
}
```

#### 2. Integration Points
- Add to `editor_toolbar.dart` or create separate panel below toolbar
- Only visible when `editorState.selectedItemId != null`
- Reads current rotation from selected item
- Updates rotation via `editorStateProvider.updateItemRotation()`

#### 3. Slider Configuration
- Range: -180° to +180° (or 0° to 360°)
- Step: 1° for precise control
- Snapping: Optional snap to 0°, 45°, 90°, etc.

#### 4. Button Actions
```dart
// Quick rotation methods
void rotateBy(double degrees) {
  final newRotation = (currentRotation + degrees) % 360;
  ref.read(editorStateProvider(entryId).notifier)
     .updateItemRotation(itemId, newRotation);
}

void resetRotation() {
  ref.read(editorStateProvider(entryId).notifier)
     .updateItemRotation(itemId, 0.0);
}
```

#### 5. Keep or Remove Handle?
**Options:**
- **Keep both**: Slider for precision, handle for quick adjustments
- **Slider only**: Remove rotation handle from bounding_box (set `enableRotate: false`)
- **Hybrid**: Hide handle on small screens, show on desktop

## User Experience Benefits

1. **Precision**: Exact degree input and fine control
2. **Speed**: Quick rotation buttons for common angles
3. **Accessibility**: Works better on touch screens
4. **Visibility**: No need to drag far from image
5. **Discoverability**: Controls are always visible when item selected

## Technical Considerations

### Dependencies
- May need slider package (or use Flutter's built-in `Slider`)
- Consider using `flutter_hooks` for smooth animations

### State Management
- Rotation state already managed by `EditorState`
- No backend changes needed
- Just UI layer addition

### Performance
- Minimal performance impact
- Use `setState` or Riverpod for reactive updates
- Debounce slider changes if needed

### Mobile Optimization
- Larger touch targets for buttons
- Slider thumb should be 44x44px minimum
- Consider responsive layout for small screens

## Acceptance Criteria

- [ ] Rotation slider with -180° to +180° range
- [ ] Current rotation value displayed
- [ ] Quick rotation buttons (+15°, -15°, reset)
- [ ] 90° rotation buttons (clockwise/counter-clockwise)
- [ ] Text input for precise degree entry
- [ ] Arrow keys work in text input for 1° adjustments
- [ ] Controls only visible when item is selected
- [ ] Works on both desktop and mobile
- [ ] Rotation updates in real-time
- [ ] Visual feedback during rotation
- [ ] Optional: Keep rotation handle or remove it

## Future Enhancements

- [ ] Rotation presets (save favorite angles)
- [ ] Animation when using quick rotation buttons
- [ ] Snap-to-angle guides (show 0°, 45°, 90° markers)
- [ ] Keyboard shortcuts (R for rotate, Shift+Arrow for rotation)
- [ ] Multi-item rotation (rotate multiple selected items together)

## Alternative Solutions Considered

### 1. Improve Current Handle
- Increase sensitivity multiplier (already at 8x)
- ❌ Doesn't solve the fundamental UX issue

### 2. Custom Rotation Handle Closer to Image
- Modify bounding_box package or fork it
- ❌ Package doesn't support handle position customization

### 3. Gesture-based Rotation
- Two-finger rotation gesture (mobile)
- ❌ Not discoverable, desktop doesn't benefit

## Estimated Effort
- **Small**: 2-3 hours for basic slider + buttons
- **Medium**: 4-6 hours for full implementation with all features
- **Large**: 8+ hours if adding circular wheel or complex UI

## Priority
**Medium-High** - Current rotation UX is a pain point but has workaround (8x sensitivity)

## Notes
- Keep the 8x sensitivity multiplier for the handle even if adding controls
- Consider making rotation control panel collapsible/expandable
- May want to add similar controls for other properties (size, position) later
