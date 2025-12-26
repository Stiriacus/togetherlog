# Feature Request: Memory Widgets (Mobile)

**Status:** Future (V3+)
**Priority:** Low
**Effort:** Medium

---

## Description

Add Android/iOS home screen widgets that periodically display random past memories.

## User Story

As a mobile user, I want to see random memories on my home screen so that I'm reminded of happy moments throughout the day.

## Requirements

### Core Features
- Android widget support
- iOS widget support
- Display random memory (photo + date + highlight text)
- Deep link to entry when tapped
- Refresh interval configuration (hourly, daily, weekly)

### Optional Features
- Multiple widget sizes (small, medium, large)
- Filter by tags (e.g., only show "Travel" memories)
- "On this day" mode (memories from same date in past years)
- Manual refresh button

## Technical Notes

- Requires platform-specific widget implementation
- Deep linking from widget to app
- Background refresh scheduling
- Image caching for widget display

## Dependencies

- V1 complete (basic entry system)
- Flutter mobile app (currently web + planned Android)

## Success Criteria

- Widget displays correctly on Android/iOS home screen
- Tapping widget opens correct entry in app
- Widget refreshes at set interval
- Minimal battery impact
