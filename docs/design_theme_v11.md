TogetherLog — Design Theme Guide (V1.1)

Status: Approved · Implementation-Ready
Scope: Application Chrome & UI System
Excludes: Smart Pages, Flipbook Internal UI
Platforms: Flutter Web (primary), Flutter Android (secondary)

1. Purpose

This document defines the global design theme for TogetherLog.

Its purpose is to:

Establish a consistent visual identity for the app shell

Ensure UI elements never compete with memory content

Provide a clear, implementable reference for Flutter developers

Act as a stable design contract alongside backend-driven Smart Pages

This theme applies to all UI outside Smart Page rendering.

2. Design Philosophy
Core Principles

Content-first: Memories are the product, UI is the frame.

Warm & cozy: Emotional, calm, human.

Journal-inspired: Subtle scrapbook feeling, not decorative.

Minimal branding: Brand presence is intentionally quiet.

Acceptable contrast: Smart Pages may clash; this is allowed.

Mental Model

The application chrome is a museum wall.
Smart Pages are the artwork.

3. Color System
3.1 Core Palette
Token	HEX	Usage
carbonBlack	#1D1E20	Primary text, anchors
darkWalnut	#592611	Primary accent, CTAs
oliveWood	#785D3A	Secondary accents, borders
softApricot	#FCDCB5	Highlights, warm surfaces
antiqueWhite	#FAEBD5	App background, cards
3.2 Functional Color Roles
Backgrounds

App background: Antique White

Cards / sheets: Antique White

Elevated highlights: Soft Apricot (sparingly)

Text

Primary: Carbon Black

Secondary: Olive Wood (80%)

Disabled / hint: Olive Wood (50%)

Actions

Primary action: Dark Walnut

Secondary action: Olive Wood

Hover / pressed overlay: Soft Apricot

3.3 Status Colors (Muted, Non-Brand)
State	Token	HEX	Usage
Success	successMuted	#6F8F7A	Processing complete, Smart Page ready
Info	infoMuted	#6F7F8F	Informational banners
Error	errorMuted	#9A5A5A	Validation and destructive warnings

Rules:

Never used for large backgrounds

Used for icons, borders, small banners only

Must not visually dominate the UI

4. Typography
4.1 Font Families (Google Fonts)
Heading Font

Playfair Display

Used for:

Screen titles

Empty state headlines

Emotional emphasis outside Smart Pages

Purpose:

Editorial, journal-like warmth

Body Font

Inter

Used for:

All body text

Forms and labels

Navigation

Metadata (dates, locations)

4.2 Type Scale
Role	Size	Weight	Font
Display / Hero	32–36	SemiBold	Playfair
Screen Title	22–24	SemiBold	Playfair
Section Header	18	Medium	Inter
Body Primary	14–16	Regular	Inter
Body Secondary	13–14	Regular	Inter
Caption / Meta	12	Regular	Inter
Button Label	14–16	Medium	Inter

Line height: 1.4–1.6 (generous, readable)

5. Spacing & Layout
5.1 Base System

8dp spacing system

5.2 Common Spacing

Small: 8

Standard: 16

Section: 24

Major: 32

5.3 Page Padding

Mobile: 16

Desktop: 24–32

6. Shape & Elevation
6.1 Border Radius
Element	Radius
Buttons	8
Inputs	8
Cards	12
Thumbnails	12–16
Chips	16
6.2 Elevation & Shadows

All shadows are warm-toned, derived from Olive Wood.

Shadow color:
rgba(120, 93, 58, 0.18)

Elevation	Offset (x,y)	Blur	Spread
1	0, 1	2	0
2	0, 2	4	0
4	0, 4	8	-1
6	0, 6	12	-2

Rules:

Never stack shadows

No black or gray shadows

Flipbook shadows are excluded

7. Component Styling
AppBar

Background: Antique White

Text/icons: Carbon Black

Elevation: 0–1

Typography: Inter

Title alignment: Left-aligned
(Auth screen only: centered)

Buttons
Primary

Background: Dark Walnut

Text: Antique White

Radius: 8

Press overlay: Soft Apricot @ 0.12

Disabled: Olive Wood @ 20% background, 50% text

Secondary

Border: Olive Wood

Text: Olive Wood

Hover: Soft Apricot @ 0.08

Text Button

Text: Dark Walnut

Hover: underline or Soft Apricot tint

Floating Action Button

Background: Dark Walnut

Icon/Text: Antique White

Extended FAB preferred

Placement: Bottom-right

Used only on:

Logs List

Entries List

Cards

Background: Antique White

Radius: 12

Elevation: 1–2

Tap feedback: Soft Apricot @ 0.08

Inputs

Background: Antique White

Border: Olive Wood @ 30%

Focus border: Dark Walnut

Error: errorMuted

Disabled:

Border: Olive Wood @ 20%

Text: Olive Wood @ 50%

Chips / Tags

Background: Soft Apricot

Text: Carbon Black

Selected: Dark Walnut background + Antique White text

Disabled: Soft Apricot @ 40%, text Olive Wood @ 50%

8. Icons
Sizes

Default: 24dp

Inline/meta: 20dp

Empty states: 48–64dp

Color Rules

Active: Dark Walnut

Inactive: Olive Wood @ 70%

Disabled: Olive Wood @ 40%

Icons inherit text color by default

No multicolor icons outside Smart Pages.

Log Type Icon Colors

Used only for log identification icons.

Log Type	HEX
Couple	#B86A7C
Friends	#6F86A8
Family	#8A6FA8

Icons only. Never backgrounds.

9. Motion & Interaction
Principles

Soft, organic, restrained

Support clarity, not attention

Timing
Interaction	Duration
Button press	120ms
Hover	150ms
Page transition	220ms
Bottom sheet	280ms
Dialog	240ms
Curves

Default: easeOutCubic

Enter: easeOut

Exit: easeIn

Flipbook page-turn animation is excluded.

10. Focus & Accessibility
Focus Ring

Color: Dark Walnut

Thickness: 2dp

Offset: 2dp

Radius: Matches component

Applies to:

Buttons

Inputs

FAB

Interactive cards

11. Dividers
Property	Value
Color	Olive Wood @ 20%
Thickness	1dp
Spacing	8–16dp

Functional only. Never decorative.

12. Placeholder & Hint Text

Placeholder text: Olive Wood @ 50%

Helper / hint text: Olive Wood @ 60%

This is intentional and must remain visually secondary.

13. Platform Adaptation
Web (Primary)

Wider max-width containers

Hover states enabled

More whitespace

Android

Slightly tighter spacing

Clear touch targets

Muted ripple effects allowed

Visual identity must remain consistent.

14. Brand Presence

No persistent logos after authentication

Brand appears primarily on:

Auth screen

Logs List AppBar

UI must never compete with memory content

15. Explicit Exclusions

This theme does NOT apply to:

Smart Page layouts

Flipbook internal UI

Emotion-Color-Engine output

Photo overlays

Smart Pages are explicitly allowed to clash visually.

16. Authority

This document is the single source of truth for TogetherLog UI theming.

Any UI change must:

Conform to this guide, or

Explicitly revise this document