Phase 1.1 — Design Tokens & Structural Primitives

These tokens are non-negotiable once defined. Widgets consume tokens; widgets never invent values.

1. Spacing System (Calm, Editorial Rhythm)
1.1 Spacing Scale (Authoritative)

Use a restricted scale. No arbitrary numbers.

Token	Value	Usage
xs	4	Icon padding, micro spacing
sm	8	Inline spacing
md	16	Card padding, form fields
lg	24	Section spacing
xl	32	Screen section separation
xxl	48	Major screen breaks

Rules

No spacing outside this scale

Vertical rhythm matters more than horizontal

Prefer spacing over dividers

2. Radius System (Premium, Soft)
2.1 Radius Tokens
Token	Radius	Usage
rSm	6	Inputs, chips
rMd	10	Cards, icon containers
rLg	16	Sheets, dialogs
rFull	999	Only when explicitly circular

Rules

Icon containers → rMd

Cards → rMd

Dialogs → rLg

Never mix radii on one surface

3. Elevation & Depth (Soft, Controlled)
3.1 Elevation Levels
Level	Usage
e0	Background
e1	Cards
e2	Icon containers
e3	Floating action buttons
e4	Overlays / dialogs

Rules

Icon containers must never exceed card elevation visually

Shadows must be warm, soft, low-contrast

No outlines + shadows together

4. Icon Container Contract (Formalized)

This implements your “darker rectangular box behind icons” requirement correctly.

4.1 Icon Container Anatomy

Background: slightly darker than surface

Radius: rMd

Padding: xs → sm

Elevation: e2

Icon centered, never edge-aligned

4.2 Usage Rules (Restated)

Allowed only for:

Primary action buttons

Inline action icons

Floating action buttons

Active navigation item only

Forbidden everywhere else.

5. Side Navigation Rail Contract
5.1 Rail Layout Rules

Fixed vertical column

Widths:

Expanded: ~240–256

Collapsed: ~72

Content area never overlaps rail

5.2 Rail Visual Rules

Background is a surface, not transparent

No heavy borders

Active item:

Icon container visible

Text emphasized

Inactive items:

No container

Muted icon color

6. Content Width Rules (Web)
6.1 Max Width Tokens
Context	Max Width
Lists	960
Forms	720
Text-heavy screens	720
Flipbook	1200+ (or fluid)

Rules

Always center content

Never edge-to-edge text on desktop

Mobile ignores max width

7. Interaction State Contract (Baseline Quality)

Every interactive component must define:

State	Required
Default	Yes
Hover (Web)	Yes
Pressed	Yes
Disabled	Yes
Loading	Yes

No exceptions.
If a component lacks states, it is incomplete.

8. Motion Baseline (Locked)
8.1 Motion Characteristics

Duration: short

Curve: ease-in-out

Distance: subtle

8.2 Allowed Motions

Fade + slight translate (dialogs)

Crossfade (navigation)

Elevation change (hover / press)

No bounce. No springy motion.