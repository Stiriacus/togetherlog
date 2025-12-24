# HOMEPAGE UI UPGRADE PLAN
## TogetherLog Design Contract Compliance Implementation

---

## 1. Homepage Audit Summary

### Current State Assessment
The LogsScreen (authenticated homepage) currently implements:
- Basic list-based layout with cards
- V1.1 theme colors and components
- Standard Material 3 Scaffold structure
- Floating action button for creation
- Three states: loading, error, data

### Major Alignment Issues

**CRITICAL VIOLATIONS:**
1. **No navigation rail** - Violates Structural UI Patterns.md canonical screen anatomy
2. **Wrong icon system** - Uses `Icons.*` (Material Icons) instead of Material Symbols Outlined
3. **Wrong typography** - Uses Playfair Display, but Typography.md mandates Inter ONLY
4. **No canonical screen structure** - Missing navigation context, header zone, breathing space zones
5. **No content width constraints** - Lists render edge-to-edge instead of max-width 960px centered
6. **Incorrect spacing tokens** - app_theme.dart:70-79 radius values don't match Design Tokens.md
7. **Incorrect icon container implementation** - log_card.dart:42-54 uses rSm(6) instead of rMd(10)

**MODERATE ISSUES:**
8. AppBar should be minimal since navigation rail provides global context
9. No breathing space between header and content
10. Card margins hardcoded instead of using spacing tokens
11. FAB placement needs rail-awareness

### Overall Maturity Level
**35% compliant** - Core theme exists, but structural patterns and governance contracts are not enforced.

---

## 2. Structural Gaps (Homepage)

### Navigation Placement Issues
- **Gap**: No side navigation rail exists
- **Required**: Fixed vertical navigation rail (240-256px expanded, ~72px collapsed)
- **Behavior**: Active destination shows icon container (rMd, e2 elevation, darker background)
- **Impact**: Violates fundamental "Navigation Context" zone requirement

### Layout and Density Problems
- **Gap**: Content renders full-width on desktop
- **Required**: List content max-width 960px, horizontally centered
- **Current**: LogList (log_list.dart:41-53) has no width constraints
- **Current**: LogCard margin hardcoded (log_card.dart:32) instead of using parent container

### Missing Hierarchy Zones
- **Gap**: No breathing space between AppBar and content
- **Required**: Intentional empty space (xl: 32px) after header before primary content
- **Current**: ListView starts immediately below AppBar

### Header Zone Structure
- **Gap**: AppBar has logout button (should be in navigation rail)
- **Required**: Screen title + optional ONE primary action (max)
- **Current**: logs_screen.dart:24-35 has title + logout action
- **Fix needed**: Move logout to navigation rail profile section

### Icon Container Misuse
- **Gap**: LogCard icon container (log_card.dart:42-48) uses 12px radius instead of rMd(10)
- **Gap**: Icon container uses `withValues(alpha: 0.1)` tint instead of "slightly darker than surface" rule
- **Required**: Background should be oliveWood with low opacity, radius rMd(10), padding xs→sm

### Typography Violations
- **Gap**: app_theme.dart:548-585 uses `GoogleFonts.playfairDisplay` for display/headline styles
- **Required**: Typography.md line 11 - "Inter" is the ONLY required font family
- **Violation**: "No serif fonts" (Typography.md:31)
- **Impact**: 6 text styles violate contract (displayLarge/Medium/Small, headlineLarge/Medium/Small)

---

## 3. Design Token Alignment Gaps

### Spacing Inconsistencies
- **Gap**: LogCard margin (log_card.dart:32) hardcoded `EdgeInsets.symmetric(horizontal: 16, vertical: 8)`
- **Required**: Use AppSpacing.md horizontal, AppSpacing.sm vertical
- **Gap**: Empty state spacing (log_list.dart:72,77) hardcoded 16px, 8px
- **Required**: Use AppSpacing.md, AppSpacing.sm
- **Gap**: No xxl(48) spacing token defined in app_theme.dart:55-62
- **Required**: Add xxl: 48 per Design Tokens.md:16

### Radius Misuse
- **Gap**: app_theme.dart radius values differ from Design Tokens.md:
  - Current: button(8), input(8), card(12), chip(16)
  - Required: rSm(6), rMd(10), rLg(16)
- **Mapping needed**:
  - Buttons/Inputs → rSm(6)
  - Cards/Icon containers → rMd(10)
  - Dialogs/Sheets → rLg(16)
  - Chips → rFull (contextual, needs review)
- **Gap**: InkWell borderRadius (log_card.dart:36) hardcoded 12, should use rMd(10)

### Elevation Misuse
- **Gap**: Elevation tokens not explicitly defined in app_theme.dart
- **Current**: AppShadows has elevation1/2/4/6 but no e0-e4 semantic naming
- **Required**: Map semantic elevation levels:
  - e0 → Background (no shadow)
  - e1 → Cards (elevation1 or elevation2)
  - e2 → Icon containers (elevation2)
  - e3 → FAB (elevation2-4)
  - e4 → Dialogs (elevation4-6)

---

## 4. Iconography & Typography Gaps

### Non-Compliant Icons
- **CRITICAL**: All icons use `Icons.*` from Flutter's default icon set
- **Required**: Material Symbols — Outlined (Iconography.md:10)
- **Flutter's Icons class**: Uses Material Icons, NOT Material Symbols
- **Solution needed**: Add `material_symbols_icons` package or migrate to explicit Material Symbols
- **Files affected**:
  - logs_screen.dart:28 (logout)
  - logs_screen.dart:44 (add)
  - log_list.dart:68 (book_outlined)
  - log_list.dart:105 (error_outline)
  - log_list.dart:128 (refresh)
  - log_card.dart:49-50,88,107,115,123,140,142,144,146 (type icons, actions)

### Icon Style Violations
- **Current**: Icons likely include filled variants (favorite, family_restroom)
- **Required**: Outlined ONLY (Iconography.md:29)
- **Verification needed**: Ensure all icon choices have outlined variants

### Incorrect Font Usage
- **CRITICAL**: Playfair Display used for 6 text styles (app_theme.dart:548-585)
- **Required**: Inter ONLY (Typography.md:11)
- **Rationale violation**: Typography.md:29-36 explicitly disallows serif fonts
- **Fix**: Replace all `GoogleFonts.playfairDisplay` with `GoogleFonts.inter`, adjust weights

### Font Weight Violations
- **Current**: displayLarge/Medium/Small use fontWeight: w600 (semibold) ✓ COMPLIANT
- **Current**: headlineLarge/Medium/Small use fontWeight: w600 ✓ COMPLIANT
- **Allowed weights**: Regular(w400), Medium(w500), Semibold(w600) per Typography.md:68-73

### Missing Hierarchy Clarity
- **Gap**: With Playfair removed, hierarchy must be established through size, weight, spacing, placement
- **Required**: Adjust screen title styling to maintain visual dominance without serif

---

## 5. Ordered Implementation Steps

### PHASE 1: Foundation Tokens (Structural Prerequisites)
**Goal**: Establish correct token foundation before any UI changes

#### Step 1.1: Fix Spacing Tokens
**Why**: Spacing is referenced throughout; must be correct first
**Where**: `app/lib/core/theme/app_theme.dart`
**What**:
- Add `xxl = 48` to AppSpacing class (line 62)
- Verify xs(4), sm(8), md(16), lg(24), xl(32) match tokens

#### Step 1.2: Fix Radius Tokens
**Why**: Radius affects cards, buttons, containers throughout app
**Where**: `app/lib/core/theme/app_theme.dart`
**What**:
- Rename AppRadius class properties to match tokens:
  - `rSm = 6` (buttons, inputs, chips)
  - `rMd = 10` (cards, icon containers)
  - `rLg = 16` (sheets, dialogs)
  - `rFull = 999` (only when explicitly circular)
- Remove `thumbnail`, `thumbnailLarge` (not in token spec)

#### Step 1.3: Create Elevation Semantic Tokens
**Why**: Elevation contract enforcement requires named levels
**Where**: `app/lib/core/theme/app_theme.dart`
**What**:
- Add AppElevation class with semantic levels:
  - `e0` → (no shadow)
  - `e1` → elevation1 (cards)
  - `e2` → elevation2 (icon containers)
  - `e3` → elevation2 or elevation4 (FAB)
  - `e4` → elevation4 or elevation6 (dialogs)

---

### PHASE 2: Typography Correction (High Impact)
**Goal**: Remove Playfair Display, establish Inter-only hierarchy

#### Step 2.1: Replace Playfair Display with Inter
**Why**: Typography.md mandates Inter ONLY; serif fonts explicitly forbidden
**Where**: `app/lib/core/theme/app_theme.dart` lines 548-585
**What**:
- Replace all `GoogleFonts.playfairDisplay` with `GoogleFonts.inter`
- Adjust hierarchy through size and weight:
  - displayLarge: Inter, 32px, w600 (reduce from 36)
  - displayMedium: Inter, 28px, w600 (reduce from 32)
  - displaySmall: Inter, 24px, w600 (reduce from 28)
  - headlineLarge: Inter, 22px, w600 (reduce from 24)
  - headlineMedium: Inter, 20px, w600 (reduce from 22)
  - headlineSmall: Inter, 18px, w600 (reduce from 20)
- Keep height: 1.4 for hierarchy, 1.5 for body text
- Maintain color: AppColors.carbonBlack

#### Step 2.2: Update Dialog Title Style
**Why**: Dialog theme (line 410) references Playfair Display
**Where**: `app/lib/core/theme/app_theme.dart` line 410
**What**:
- Change `GoogleFonts.playfairDisplay` to `GoogleFonts.inter`
- Adjust to 20px, w600 to maintain dialog title prominence

---

### PHASE 3: Icon System Migration (Critical)
**Goal**: Replace Material Icons with Material Symbols Outlined

#### Step 3.1: Add Material Symbols Package
**Why**: Flutter's `Icons.*` uses Material Icons, not Material Symbols
**Where**: `app/pubspec.yaml`
**What**:
- Research and add appropriate package (e.g., `material_symbols_icons: ^latest`)
- Run `flutter pub get`
- Document import pattern for team

#### Step 3.2: Create Icon Constants Helper
**Why**: Centralize icon choices, enforce outlined variant
**Where**: Create `app/lib/core/theme/app_icons.dart`
**What**:
- Create AppIcons class with static constants for all app icons:
  - `logout`, `add`, `book`, `error`, `refresh`
  - `favorite`, `familyRestroom`, `person`
  - `menuBook`, `edit`, `delete`, `moreVert`
- Use Material Symbols Outlined variants ONLY
- Add documentation comment: "All icons use Material Symbols - Outlined per Iconography.md"

#### Step 3.3: Replace Icon References in LogsScreen
**Why**: Homepage must be reference implementation
**Where**: `app/lib/features/logs/logs_screen.dart`
**What**:
- Line 28: Replace `Icons.logout` with `AppIcons.logout`
- Line 44: Replace `Icons.add` with `AppIcons.add`
- Add import for AppIcons

#### Step 3.4: Replace Icon References in LogList
**Why**: Loading, error, empty states must comply
**Where**: `app/lib/features/logs/widgets/log_list.dart`
**What**:
- Line 68: Replace `Icons.book_outlined` with `AppIcons.book`
- Line 105: Replace `Icons.error_outline` with `AppIcons.error`
- Line 128: Replace `Icons.refresh` with `AppIcons.refresh`

#### Step 3.5: Replace Icon References in LogCard
**Why**: Card icons are primary UI surface
**Where**: `app/lib/features/logs/widgets/log_card.dart`
**What**:
- Line 88: `Icons.more_vert` → `AppIcons.moreVert`
- Line 107: `Icons.menu_book` → `AppIcons.menuBook`
- Line 115: `Icons.edit` → `AppIcons.edit`
- Line 123: `Icons.delete` → `AppIcons.delete`
- Lines 140-146: Update `_getTypeIcon()` to use AppIcons variants

---

### PHASE 4: Navigation Rail Implementation (Most Critical)
**Goal**: Introduce side navigation rail per Structural UI Patterns.md

#### Step 4.1: Create Navigation Rail Widget
**Why**: Reusable rail component for all authenticated screens
**Where**: Create `app/lib/core/navigation/app_navigation_rail.dart`
**What**:
- Create StatefulWidget `AppNavigationRail`
- Implement expanded/collapsed states
- Width: 240px expanded, 72px collapsed
- Background: AppColors.antiqueWhite (surface)
- Active item: Icon container with rMd radius, e2 elevation, darker background
- Inactive items: Icon only, muted color (AppColors.inactiveIcon)
- Destinations:
  - Logs (book icon)
  - Settings/Profile (person icon)
  - Logout (logout icon, bottom-aligned)
- Use Material Symbols Outlined icons from AppIcons
- Implement toggle button (collapse/expand)

#### Step 4.2: Create Icon Container Component
**Why**: Enforce icon container contract from Design Tokens.md:61-89
**Where**: Create `app/lib/core/widgets/icon_container.dart`
**What**:
- Create `IconContainer` widget
- Parameters: icon, size, isActive
- Implementation:
  - Background: `oliveWood.withValues(alpha: 0.15)` (slightly darker than surface)
  - Radius: rMd (10)
  - Padding: xs (4) for small, sm (8) for standard
  - Elevation: e2 (elevation2 shadow)
  - Icon centered, never edge-aligned
- Add assertion: Only render if isActive or context is primary action

#### Step 4.3: Create Shell Layout Widget
**Why**: Canonical screen anatomy requires navigation + content structure
**Where**: Create `app/lib/core/layouts/authenticated_shell.dart`
**What**:
- Create `AuthenticatedShell` widget
- Layout: Row([AppNavigationRail, Expanded(content)])
- Pass current route to rail for active state
- Handle responsive: desktop shows rail, mobile shows drawer overlay
- Constrain content width per Design Tokens.md:122-128:
  - Lists: max-width 960px, centered
  - Forms: max-width 720px, centered

---

### PHASE 5: Homepage Restructuring (Canonical Anatomy)
**Goal**: Apply canonical screen anatomy to LogsScreen

#### Step 5.1: Wrap LogsScreen in AuthenticatedShell
**Why**: Introduce navigation rail to homepage
**Where**: `app/lib/features/logs/logs_screen.dart`
**What**:
- Remove Scaffold wrapper
- Return content only (header + body)
- Shell provides navigation context
- Remove logout button from AppBar (now in rail)

#### Step 5.2: Implement Header Zone
**Why**: Header zone rules require title dominance, breathing space
**Where**: `app/lib/features/logs/logs_screen.dart`
**What**:
- Create header zone:
  - Screen title "Your Logs" (titleLarge or headlineSmall)
  - No actions (FAB provides primary action)
  - Padding: horizontal md(16), top md(16)
- Remove AppBar entirely (rail provides global context)

#### Step 5.3: Add Breathing Space
**Why**: Structural UI Patterns.md requires intentional empty space
**Where**: Between header zone and primary content
**What**:
- Add SizedBox(height: AppSpacing.xl) // 32px after header zone
- Rationale: "Breathing Space — Intentional empty space before content"

#### Step 5.4: Constrain Content Width
**Why**: Design Tokens.md:123 - Lists max-width 960
**Where**: `app/lib/features/logs/widgets/log_list.dart`
**What**:
- Wrap ListView.builder in Center + ConstrainedBox
- maxWidth: 960
- Alignment: center
- Remove horizontal margin from LogCard (parent provides constraint)

#### Step 5.5: Update LogCard Spacing
**Why**: Use spacing tokens, remove hardcoded values
**Where**: `app/lib/features/logs/widgets/log_card.dart`
**What**:
- Line 32: Remove `margin` parameter (parent constrains width)
- Line 36: Change borderRadius from `12` to `AppRadius.rMd` // 10
- Line 38: Change padding from `16` to `AppSpacing.md`
- Line 45-48: Update icon container:
  - width/height: 48 (reduced from 56, more appropriate for rMd container)
  - borderRadius: `AppRadius.rMd` (10, not 12)
  - Background: `AppColors.oliveWood.withValues(alpha: 0.15)` (darker, not tinted)
- Line 55: Change SizedBox from `16` to `AppSpacing.md`
- Lines 70,77: Change SizedBox from `4` to `AppSpacing.xs`

---

### PHASE 6: Interaction States & Polish
**Goal**: Ensure all interactive elements have required states

#### Step 6.1: Add FAB Rail-Awareness
**Why**: FAB must position correctly with navigation rail present
**Where**: Shell layout or individual screen
**What**:
- Position FAB in content area, not overlapping rail
- Maintain bottom-right positioning relative to content, not viewport

#### Step 6.2: Verify Hover States
**Why**: Design Tokens.md:143 - Hover required for all interactive components
**Where**: LogCard, navigation rail items
**What**:
- LogCard InkWell: Already has hover via Material (✓)
- Navigation rail items: Implement hover overlay (AppColors.hoverOverlay)

#### Step 6.3: Enhance Loading State
**Why**: Loading philosophy - users tolerate waiting when they understand progress
**Where**: `app/lib/features/logs/widgets/log_list.dart` line 90
**What**:
- Replace bare CircularProgressIndicator with:
  - Center + Column
  - CircularProgressIndicator
  - SizedBox(height: AppSpacing.md)
  - Text("Loading your logs...", style: bodySmall, color: secondaryText)

#### Step 6.4: Refine Empty State
**Why**: Empty states answer: Where am I? Why empty? What next?
**Where**: `app/lib/features/logs/widgets/log_list.dart` lines 62-86
**What**:
- Verify icon uses AppIcons.book (Material Symbols Outlined)
- Verify spacing uses tokens:
  - Line 72: Change `16` to `AppSpacing.md`
  - Line 77: Change `8` to `AppSpacing.sm`
- Verify text tone: "No logs yet" + "Create your first memory book" (✓ calm, reassuring)

---

### PHASE 7: Theme Consolidation
**Goal**: Update ThemeData to use corrected tokens

#### Step 7.1: Update Button Themes with New Radius
**Why**: Buttons should use rSm(6) per tokens
**Where**: `app/lib/core/theme/app_theme.dart` lines 205-303
**What**:
- ElevatedButton: borderRadius rSm (line 218)
- FilledButton: borderRadius rSm (line 239)
- OutlinedButton: borderRadius rSm (line 260)
- TextButton: already correct (no explicit border)
- FAB: borderRadius rSm (line 314)

#### Step 7.2: Update Card Theme with New Radius
**Why**: Cards should use rMd(10) per tokens
**Where**: `app/lib/core/theme/app_theme.dart` line 199
**What**:
- Change borderRadius from `AppRadius.card` to `AppRadius.rMd`

#### Step 7.3: Update Input Theme with New Radius
**Why**: Inputs should use rSm(6) per tokens
**Where**: `app/lib/core/theme/app_theme.dart` lines 327-349
**What**:
- Change all `AppRadius.input` references to `AppRadius.rSm`

#### Step 7.4: Update Chip Theme with New Radius
**Why**: Chips should use rSm(6) per tokens (or rFull if fully rounded)
**Where**: `app/lib/core/theme/app_theme.dart` line 390
**What**:
- Evaluate: Current 16px radius suggests pill shape
- If pills: Change to `AppRadius.rFull` (999)
- If rectangular chips: Change to `AppRadius.rSm` (6)
- Decision needed: Check design intent

#### Step 7.5: Update Dialog Theme with New Radius
**Why**: Dialogs should use rLg(16) per tokens
**Where**: `app/lib/core/theme/app_theme.dart` line 408
**What**:
- Change borderRadius from `AppRadius.card` to `AppRadius.rLg`

#### Step 7.6: Update Bottom Sheet Theme with New Radius
**Why**: Sheets should use rLg(16) per tokens
**Where**: `app/lib/core/theme/app_theme.dart` line 428
**What**:
- Change borderRadius from `AppRadius.card` to `AppRadius.rLg`

#### Step 7.7: Update Snackbar Theme with New Radius
**Why**: Snackbar should use rSm(6) (button-like)
**Where**: `app/lib/core/theme/app_theme.dart` line 441
**What**:
- Change borderRadius from `AppRadius.button` to `AppRadius.rSm` (semantically same, but use token)

---

## 6. Completion Criteria (Homepage)

### Visual Criteria
- [ ] Navigation rail visible on left with proper width (240px expanded / 72px collapsed)
- [ ] Active navigation item has icon container (rMd, e2, darker background)
- [ ] Inactive navigation items show icon only, muted color
- [ ] Screen title "Your Logs" has visual dominance in header zone
- [ ] Breathing space (32px) visible between header and content
- [ ] Log list centered with max-width 960px on desktop
- [ ] All icons use Material Symbols Outlined style (verified visually)
- [ ] LogCard icon containers use rMd(10) radius
- [ ] All text uses Inter font family (no Playfair Display)
- [ ] Empty state feels calm and reassuring
- [ ] Loading state shows progress context
- [ ] FAB positioned correctly relative to content area (not viewport)

### Structural Criteria
- [ ] Canonical screen anatomy zones identifiable:
  - [ ] Navigation Context (rail)
  - [ ] Screen Header Zone (title)
  - [ ] Breathing Space (32px gap)
  - [ ] Primary Content (log list)
  - [ ] Secondary Content (none on homepage, but FAB provides action)
- [ ] No hardcoded spacing values; all use AppSpacing tokens
- [ ] No hardcoded radius values; all use AppRadius tokens
- [ ] Icon container implementation matches contract exactly
- [ ] Content width constraints applied per token rules

### Behavioral Criteria
- [ ] Navigation rail toggles between expanded/collapsed states
- [ ] Active navigation destination updates on route change
- [ ] Logout action works from navigation rail
- [ ] Hover states present on all interactive elements (Web)
- [ ] Press feedback immediate and visible
- [ ] Loading state provides context ("Loading your logs...")
- [ ] Empty state answers: Where am I? Why empty? What next?
- [ ] LogCard interactions (tap, edit, delete, flipbook) work correctly
- [ ] FAB creates new log
- [ ] Content area doesn't overlap navigation rail

### Code Quality Criteria
- [ ] No import of `Icons.*` class in homepage files (use AppIcons)
- [ ] No import of `GoogleFonts.playfairDisplay` anywhere
- [ ] All spacing references use `AppSpacing.*` constants
- [ ] All radius references use `AppRadius.r*` constants
- [ ] All elevation references use `AppElevation.e*` constants
- [ ] IconContainer widget reusable and contract-compliant
- [ ] AuthenticatedShell reusable for all authenticated screens
- [ ] AppNavigationRail reusable and state-aware
- [ ] No design contract violations flagged by code review

---

## Notes on Plan Execution

**This plan is deterministic and sequential.** Each phase builds on the previous:
- Phase 1 establishes tokens (foundation)
- Phase 2 fixes typography (high visual impact)
- Phase 3 migrates icons (design system integrity)
- Phase 4 implements navigation (structural requirement)
- Phase 5 restructures homepage (canonical anatomy)
- Phase 6 adds interaction polish (quality baseline)
- Phase 7 consolidates theme (system-wide consistency)

**No steps should be skipped.** Each step includes rationale (Why), location (Where), and specification (What).

**Homepage becomes reference implementation.** Once complete, this structure and pattern should be replicated on all other screens (Entries, Flipbook, Auth, etc.).

**Design contracts are non-negotiable.** Any deviation from Design Tokens.md, Structural UI Patterns.md, Iconography.md, or Typography.md must be flagged and corrected.
