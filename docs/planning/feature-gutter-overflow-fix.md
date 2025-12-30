# Feature Request: Fix Gutter Panel Overflow Warnings

## Summary
Eliminate RenderFlex overflow warnings that occur in both left and right gutter panels during collapsed state transitions.

## Problem Description

When the gutter panels are in collapsed state (48px width), collapsible section headers generate overflow warnings:

```
A RenderFlex overflowed by 16-23 pixels on the right.
constraints: BoxConstraints(0.0<=w<=32.0, 0.0<=h<=Infinity)
```

**Root Cause:**
The Row widget in `_buildCollapsibleSection` renders with:
- Icon: 20px
- Spacing: 8px (AppSpacing.sm)
- Text (Expanded)
- Chevron: 20px
- Padding: 16px (8px × 2)

Total = 48px+ content, but available width is only 32px (48px - 16px padding) when collapsed.

**Affected Files:**
- `app/lib/features/page_editor/widgets/left_gutter_panel.dart`
- `app/lib/features/page_editor/widgets/right_gutter_panel.dart`

## Current Behavior

- Overflow warnings appear in console during development
- Warnings occur when panels are collapsed or during collapse animation
- No visual issues in production UI
- Section headers should not be visible when collapsed, but may render briefly during transitions

## Expected Behavior

- No overflow warnings in console
- Section headers should be completely hidden when panels are collapsed
- Smooth transitions without intermediate rendering of hidden content

## Proposed Solution

**Option 1: Conditional Rendering Guard**
Wrap collapsible sections in conditional rendering that checks parent panel expansion state:

```dart
// Only render sections when panel is expanded
if (widget.isExpanded) ...[
  _buildCollapsibleSection(...),
]
```

**Option 2: Overflow Clipping**
Add overflow clipping to Row widgets in section headers:

```dart
child: Row(
  children: [...],
  overflow: Overflow.clip,
)
```

**Option 3: Responsive Layout**
Adjust section header layout based on available width using LayoutBuilder.

## Recommendation

Use **Option 1** (Conditional Rendering Guard) because:
- Prevents unnecessary rendering when collapsed
- Better performance (fewer widgets in tree)
- Eliminates root cause rather than hiding symptoms
- Consistent with Flutter best practices

## Implementation Notes

1. Wrap all `_buildCollapsibleSection` calls with `if (widget.isExpanded)`
2. Ensure collapsed icons remain visible in collapsed state
3. Test transitions to ensure no visual glitches
4. Verify performance improvement with Flutter DevTools

## Priority

**Low** - Visual development warning only, no functional impact

## Version Target

V2.0+ (UX polish)
