# Feature Request: Relationship Progress System (Gamification)

**Status:** Future (V3+)
**Priority:** Low
**Effort:** Large

---

## Description

Add optional gamification with XP system and category-based levels to encourage creating diverse memories.

## User Story

As a user, I want to see our relationship "level up" as we create memories together so that we're motivated to try new activities and build a richer shared history.

## Requirements

### Core Features
- **XP System**
  - Earn XP for creating entries
  - Bonus XP for certain tags (rare activities)
  - Overall relationship level

- **Category Levels**
  - Travel Level (based on travel tags + location diversity)
  - Adventure Level (based on sports, hiking, adventure tags)
  - Romance Level (based on romantic tags + couple activities)
  - Foodie Level (based on food/restaurant entries)

- **Visual Indicators**
  - Progress bars on profile/log page
  - Achievement badges
  - Level-up celebrations

### Optional Features
- Leaderboard (if multi-log support added)
- Achievements system (e.g., "Visited 10 countries")
- Suggested activities to level up specific categories
- Optional: toggle feature on/off per log

## Technical Notes

- Requires new `log_stats` table or JSONB field
- Background computation of levels
- Achievement detection logic

## Dependencies

- V1 complete (basic entry/tag system)

## Success Criteria

- Levels increase as users add entries
- Category breakdown is accurate
- Feature is optional (not forced on all users)
- Achievements feel rewarding, not annoying
