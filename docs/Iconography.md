Purpose

This document defines the only allowed icon system for TogetherLog and the rules governing icon usage.

Icons are functional affordances, not decoration.

1. Icon System (Locked)
Primary Icon Set

Material Symbols — Outlined

This is the only icon family permitted.

Rationale

Native alignment with Material 3

Excellent Flutter + Web support

Consistent optical sizing

Large, complete icon library

Neutral, editorial tone (non-playful)

2. Icon Style Rules
Variant

Outlined only

No Filled

No Rounded

No Sharp

Weight & Optical Consistency

Default stroke weight

No custom SVGs

No resizing to “make it feel right”

Icons must look consistent across the entire app.

3. Icon Usage Philosophy

Icons communicate action, not emotion.

Icons MUST:

Represent a clear, universal action

Be immediately recognizable

Reinforce hierarchy, not compete with text

Icons MUST NOT:

Be decorative

Replace text labels where clarity suffers

Be used “because it looks empty”

If text alone is sufficient, do not add an icon.

4. Where Icons Are Allowed
Primary Contexts

Navigation destinations

Primary actions

Inline action controls (edit, delete, more)

Floating action buttons

Secondary Contexts (Limited)

Metadata indicators (only if universally understood)

5. Icon Containers (Cross-Reference)

Icon containers are governed by Structural UI Patterns.md.

Summary reminder:

Rounded rectangle

Soft elevation

Used only for meaningful actions

Never for decoration

Icons do not become stronger by increasing size or weight.
Emphasis is achieved through container and placement, not icon styling.

6. Icon Size Scale (Conceptual)

Icons follow a fixed, limited scale:

Small: inline actions

Medium: navigation & primary actions

Large: floating actions only

No arbitrary scaling.

7. Forbidden Practices

The following are explicitly forbidden:

Mixing icon families

Mixing outlined and filled styles

Custom SVG icons

Emojis as icons

Using icons to replace clear text labels

Overloading screens with icons

Any of the above constitutes a design violation.

8. Design Integrity Rule

If two icons on the same screen do not look like they belong together, the screen is incorrect.