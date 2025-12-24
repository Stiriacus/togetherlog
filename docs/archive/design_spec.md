# TogetherLog Design Specification

**Version:** 1.0
**Status:** Current State Documentation
**Scope:** Application Chrome & Structure (excludes Smart Page content design)

---

## Table of Contents

1. [Overview](#overview)
2. [Screen Inventory](#screen-inventory)
3. [Global UI Elements](#global-ui-elements)
4. [Screen-Specific UI Elements](#screen-specific-ui-elements)
5. [Component Library](#component-library)
6. [Layout Patterns](#layout-patterns)
7. [Visual Neutrality Guidelines](#visual-neutrality-guidelines)
8. [Navigation Architecture](#navigation-architecture)

---

## Overview

### Design Philosophy

TogetherLog is a memory-focused flipbook application. The application chrome (navigation, forms, lists) must remain visually neutral and unobtrusive to allow photo-driven Smart Pages to be the visual centerpiece.

### Platform Targets

- Flutter Web (primary development target)
- Android (secondary target)

### Theme Constraint

- Light theme only (no dark mode)

### Core Principle

> The application shell exists to facilitate access to memories, not to compete with them visually.

---

## Screen Inventory

### MVP Flow (7 Screens)

| Screen | Route | Purpose | Auth Required |
|--------|-------|---------|---------------|
| Auth | `/auth` | Login and signup | No |
| Logs List | `/logs` | View and manage memory logs | Yes |
| Entries List | `/logs/:logId/entries` | View entries within a log | Yes |
| Entry Create | `/logs/:logId/entries/create` | Create new memory entry | Yes |
| Entry Detail | `/entries/:entryId` | View entry details | Yes |
| Entry Edit | `/entries/:entryId/edit` | Modify existing entry | Yes |
| Flipbook Viewer | `/logs/:logId/flipbook` | Immersive page-turn experience | Yes |

### User Journey

```
Auth → Logs List → Entries List → Entry Detail
                 ↓              ↓
              Flipbook    Create/Edit Entry
```

---

## Global UI Elements

### Elements Present Across Multiple Screens

#### 1. AppBar (Standard Pattern)

**Position:** Top, fixed
**Present on:** All screens except Auth

| Component | Position | Behavior |
|-----------|----------|----------|
| Back/Close button | Leading (left) | Context-dependent navigation |
| Screen title | Center-left | Descriptive text |
| Action buttons | Trailing (right) | Screen-specific actions |

#### 2. Loading State

**Position:** Center
**Component:** CircularProgressIndicator
**Usage:** Data fetching, form submission, image loading

#### 3. Error State

**Position:** Center
**Components:**
- Error icon (top)
- Error message (middle)
- Retry button (bottom)

#### 4. Empty State

**Position:** Center
**Components:**
- Large contextual icon (top)
- "No [items] yet" message (middle)
- Optional call-to-action (bottom)

#### 5. Floating Action Button (FAB)

**Position:** Bottom-right
**Present on:** Logs List, Entries List
**Style:** Extended FAB with icon and label

---

## Screen-Specific UI Elements

### 1. Auth Screen

**AppBar:** None (standalone screen)

| Element | Position | Description |
|---------|----------|-------------|
| App icon | Top-center | Branding element (book icon) |
| App title | Top-center, below icon | "TogetherLog" |
| Subtitle | Top-center, below title | Tagline text |
| Tab bar | Center | Login / Sign Up toggle |
| Form fields | Center | Email, password inputs |
| Submit button | Center, below form | Primary action |
| Error/Success messages | Above submit button | Feedback container |

**Layout:** Centered container with max-width constraint (500px)

---

### 2. Logs List Screen

**AppBar Configuration:**
- Title: "TogetherLog"
- Actions: Logout button (icon only)

| Element | Position | Description |
|---------|----------|-------------|
| Log cards | Body (scrollable list) | Tappable cards with log info |
| FAB | Bottom-right | "New Log" action |

**Log Card Structure:**
- Left: Type icon in colored container
- Center: Log name, type label, created date
- Right: More options menu

**Interactions:**
- Tap card → Navigate to entries
- Tap more options → Bottom sheet with actions

---

### 3. Entries List Screen

**AppBar Configuration:**
- Title: "Entries"
- Leading: Back button → Logs List
- Actions: Flipbook button (icon)

| Element | Position | Description |
|---------|----------|-------------|
| Entry cards | Body (scrollable list) | Cards with thumbnail preview |
| Pull-to-refresh | Body | RefreshIndicator wrapper |
| FAB | Bottom-right | "New Entry" action |

**Entry Card Structure:**
- Top: Photo thumbnail (if available)
- Content: Date, highlight text, location
- Footer: Photo count, Smart Page badge
- Actions: Edit and Delete buttons (divided row)

---

### 4. Entry Create Screen

**AppBar Configuration:**
- Title: "New Entry"
- Leading: Close button (X icon)

| Element | Position | Description |
|---------|----------|-------------|
| Date picker | Form section | ListTile with calendar icon |
| Highlight field | Form section | Multi-line text input |
| Photo picker | Form section | Horizontal thumbnail list + buttons |
| Tag selector | Form section | Grouped filter chips |
| Location editor | Form section | Toggle + text input |
| Submit button | Form bottom | Full-width primary button |

**Form Layout:** Vertical scrolling ListView with section spacing

---

### 5. Entry Detail Screen

**AppBar Configuration:**
- Title: "Entry Details"
- Actions: Edit button (icon)

| Element | Position | Description |
|---------|----------|-------------|
| Event date | Content top | Calendar icon + formatted date |
| Highlight text | Content, prominent | Large text display |
| Location | Below highlight | Location icon + display name |
| Smart Page status | Below location | Status badge (if processed) |
| Photos grid | Content section | 2-column grid layout |
| Tags | Content bottom | Wrapped chip display |

**Layout:** SingleChildScrollView with vertical sections

---

### 6. Entry Edit Screen

**AppBar Configuration:**
- Title: "Edit Entry"
- Leading: Close button (X icon)

| Element | Position | Description |
|---------|----------|-------------|
| Info banner | Form top | Blue notice about photo limitations |
| Date picker | Form section | Same as Create |
| Highlight field | Form section | Pre-populated text input |
| Tag selector | Form section | Pre-selected tags |
| Location editor | Form section | Pre-populated location |
| Submit button | Form bottom | "Update Entry" button |

**Note:** Photos cannot be edited (info banner explains this)

---

### 7. Flipbook Viewer Screen

**AppBar Configuration:**
- Title: Log name (dynamic)
- Background: Dark gray (contrasts with book)
- Text: White

**Distinct from other screens:** Uses dark theme for immersive reading

| Element | Position | Description |
|---------|----------|-------------|
| PageFlipWidget | Center (body) | 3D page-turn animation container |
| Previous button | Bottom-left (overlay) | Navigation chevron |
| Page indicator | Bottom-center (overlay) | "X / Y" text |
| Next button | Bottom-right (overlay) | Navigation chevron |

**Smart Page Content:** Rendered by SmartPageRenderer (backend-computed layouts)

**Final Page:** "The End" summary page with completion icon

---

## Component Library

### Input Components

| Component | Usage | Key Attributes |
|-----------|-------|----------------|
| TextFormField | Text input | Rounded border, gray fill, icon prefix |
| DropdownButtonFormField | Selection | Same styling as text fields |
| DatePicker | Date selection | Material date picker dialog |
| SwitchListTile | Boolean toggle | On/off with label |
| CheckboxListTile | Boolean toggle | Checked state with label |
| FilterChip | Multi-select | Selected state highlight, checkmark |

### Display Components

| Component | Usage | Key Attributes |
|-----------|-------|----------------|
| Card | Container | Elevation 2, rounded corners |
| Chip | Tag display | Read-only label |
| ListTile | Row item | Icon, title, subtitle pattern |
| Badge | Status indicator | Colored container with text |

### Action Components

| Component | Usage | Key Attributes |
|-----------|-------|----------------|
| FilledButton | Primary action | Full-width, prominent |
| TextButton | Secondary action | Low emphasis |
| IconButton | Icon-only action | AppBar and inline |
| FloatingActionButton.extended | Primary screen action | Icon + label |

### Feedback Components

| Component | Usage | Key Attributes |
|-----------|-------|----------------|
| CircularProgressIndicator | Loading | Centered, indeterminate |
| SnackBar | Toast messages | Bottom-positioned |
| AlertDialog | Confirmations | Title, content, actions |
| BottomSheet | Action menus | Slide-up panel |

---

## Layout Patterns

### Spacing System

Base unit: 8px

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Tight spacing |
| sm | 8px | Component internal |
| md | 16px | Section padding |
| lg | 24px | Section separation |
| xl | 32px | Major divisions |

### Border Radius

| Context | Radius |
|---------|--------|
| Input fields | 8px |
| Cards | 8-12px |
| Buttons | 8px |
| Photo thumbnails | 8-16px |
| Chips | 16px (pill) |

### Responsive Constraints

| Screen | Constraint |
|--------|------------|
| Auth | max-width: 500px, centered |
| Flipbook | aspect-ratio: 0.7 (portrait book) |
| All others | Full width, standard padding |

### Grid Specifications

| Context | Columns | Spacing |
|---------|---------|---------|
| Photos grid (detail) | 2 | 8px |
| Photo grid (2x2 layout) | 2 | 12px |
| Photo grid (3x2 layout) | 3 | 10px |
| Tags wrap | Flow layout | 8px |

---

## Visual Neutrality Guidelines

### Purpose

The application chrome must not compete with user photos and Smart Page themes. These guidelines ensure visual harmony.

### Neutral Zones (Must Remain Subdued)

| Element | Guideline |
|---------|-----------|
| AppBar | Standard Material elevation, no custom backgrounds |
| Form containers | White/light gray, no decorative elements |
| Cards (list views) | Minimal shadow, neutral borders |
| Navigation controls | Semi-transparent, icon-only where possible |
| Buttons | Use theme primary color sparingly |
| Empty states | Grayscale icons, muted text |

### Photo-Dominant Zones

| Element | Guideline |
|---------|-----------|
| Flipbook pages | Full bleed to content edges |
| Entry card thumbnails | No borders, natural aspect ratio |
| Photo grids | Minimal gaps, rounded corners only |

### Elements That May Use Color

| Element | Color Purpose |
|---------|---------------|
| Log type icons | Category identification (pink, blue, purple) |
| Tag chips (selected) | Indicate selection state |
| Smart Page badge | Success/status indicator (green) |
| Error messages | Alert state (red) |
| Info banners | Informational state (blue) |

### Smart Page Isolation

Smart Page themes (warm_red, earth_green, ocean_blue, deep_purple, warm_earth, soft_rose, neutral) apply **only** within:
- FlipbookViewer → SmartPageRenderer
- Never bleed into application chrome

The flipbook viewer uses a dark gray background specifically to:
1. Create visual separation from the "book" content
2. Avoid color clashing with any Smart Page theme
3. Focus attention on the memory content

---

## Navigation Architecture

### Route Hierarchy

```
/auth                           (unauthenticated)
/logs                           (authenticated home)
  └── /logs/:logId/entries      (log context)
        ├── /logs/:logId/entries/create
        └── /logs/:logId/flipbook
/entries/:entryId               (entry context)
  └── /entries/:entryId/edit
```

### Navigation Patterns

| From | To | Trigger | Method |
|------|-----|---------|--------|
| Auth | Logs | Successful login | Replace (redirect) |
| Logs | Auth | Logout | Replace (redirect) |
| Logs | Entries | Tap log card | Push |
| Entries | Logs | AppBar back | Pop |
| Entries | Create | Tap FAB | Push |
| Entries | Detail | Tap entry card | Push |
| Entries | Flipbook | Tap flipbook icon | Push |
| Detail | Edit | Tap edit icon | Push |
| Create/Edit | Previous | Tap close | Pop |

### Auth Guards

- Unauthenticated users → Redirect to `/auth`
- Authenticated users on `/auth` → Redirect to `/logs`

### No Bottom Navigation

The app uses hierarchical navigation (AppBar-based) rather than flat navigation (bottom tabs). This decision:
- Reinforces the log → entry → content hierarchy
- Reduces visual clutter
- Aligns with the memory-journal mental model

---

## Appendix: Screen Element Summary

### Quick Reference Matrix

| Screen | AppBar | FAB | Pull-Refresh | Overlay Controls |
|--------|--------|-----|--------------|------------------|
| Auth | No | No | No | No |
| Logs List | Yes | Yes | Yes | No |
| Entries List | Yes | Yes | Yes | No |
| Entry Create | Yes | No | No | No |
| Entry Detail | Yes | No | No | No |
| Entry Edit | Yes | No | No | No |
| Flipbook | Yes (dark) | No | No | Yes (navigation) |

### Action Placement Summary

| Action Type | Placement |
|-------------|-----------|
| Primary screen action | FAB (bottom-right) or Full-width button (form bottom) |
| Secondary screen action | AppBar actions (right) |
| Navigation back/close | AppBar leading (left) |
| Item actions | Inline buttons or overflow menu |
| Destructive actions | Confirmation dialog required |

---

*This document describes the current implementation state and serves as a reference for maintaining design consistency across the application.*
