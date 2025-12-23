Phase 1.2 — Structural UI Patterns (Theory Only)

This phase defines canonical UI patterns. Every screen must be composed from these patterns. No screen is “special”.

1. Canonical Screen Anatomy

Every TogetherLog screen follows this vertical stack:

Navigation Context
Side rail establishes global context immediately.

Screen Header Zone

Screen title

Optional primary action

Never crowded

Breathing Space
Intentional empty space before content.

Primary Content Block
Lists, forms, pages.

Secondary / Supporting Content
Metadata, hints, secondary actions.

Rule:
If you cannot identify these zones on a screen, the screen is incorrectly structured.

2. Header Zone Rules
Purpose

Orient the user. Nothing else.

Rules

One primary action maximum

No stacked buttons

No dense icon clusters

Title always has visual dominance

Psychological effect
Users feel “settled” before engaging with content.

3. List Screen Pattern (Logs / Entries)

This is the most important pattern.

Visual Structure

Cards float gently on background

Clear vertical rhythm

No hard separators

Content Hierarchy Inside a Card

Primary label (what this is)

Emotional or contextual highlight

Metadata (date, count, location)

Rule
Metadata must never visually compete with primary content.

4. Detail Screen Pattern (Entry Detail)
Content Ordering

Emotional core (photo / page)

Main text or memory

Tags / metadata

Actions

Rule
Actions are always last unless they are destructive.

5. Forms & Creation Screens

Forms should feel supportive, not transactional.

Rules

One column only

Labels above inputs

Generous spacing

No inline validation unless critical

Emotional Goal
User feels guided, not evaluated.

6. Icon Container Pattern (Theory)

Icon containers exist to communicate:

“This is a tool, not decoration.”

Behavioral Rules

Appears only when action is meaningful

Never repeated excessively in one area

Disappears when inactive unless primary

If you see many icon containers clustered together → misuse.

7. Navigation Rail Behavior (User Mental Model)
Expanded State

“I know where I am”

Labels visible

Calm, editorial

Collapsed State

“I’m focused”

Icons only

Minimal intrusion

Overlay State (Mobile)

“I’m navigating”

Temporary

Dismisses cleanly

Rule
Navigation must never compete with content emotionally.

Phase 1.3 — Interaction & Feedback Theory

This phase defines how the app feels, not how it looks.

8. Feedback Hierarchy

Not all feedback is equal.

Priority Order

Press feedback (immediate)

Loading feedback

Success confirmation

Error handling

Rule
If the user presses something and nothing happens immediately, the UI is broken.

9. Loading Philosophy
Allowed

Skeletons

Soft placeholders

Progressive reveal

Forbidden

Blocking overlays

Indeterminate spinners without context

Psychology
Users tolerate waiting when they understand progress.

10. Empty States (Emotional, Not Clever)

Empty states answer three questions:

Where am I?

Why is this empty?

What should I do next?

Tone

Calm

Reassuring

Non-marketing

No humor. No illustrations unless extremely subtle.

11. Motion Theory

Motion should feel like paper and space, not software tricks.

Rules

Motion connects states

Motion never decorates

Motion stops as soon as comprehension is achieved

If motion is noticed, it is already too strong.