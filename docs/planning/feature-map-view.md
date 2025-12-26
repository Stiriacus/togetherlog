# Feature Request: Interactive Map View

**Status:** Future (V3+)
**Priority:** Medium
**Effort:** Large

---

## Description

Add an interactive world/region map showing all memory entries with location data as markers.

## User Story

As a user, I want to see all my memories on a map so that I can explore them geographically and relive trips visually.

## Requirements

### Core Features
- Interactive map using OpenStreetMap + Leaflet (or flutter_map)
- Each entry with coordinates appears as a map marker
- Click marker → open corresponding entry/page in flipbook
- Cluster markers for dense areas

### Optional Features
- Filter by tags (e.g., show only "Beach" entries)
- Filter by date range
- Zoom to fit all markers
- Heatmap mode showing visit frequency

## Technical Notes

- Uses existing `location_lat`, `location_lng` from entries table
- Requires map library integration
- Consider performance with 100+ markers

## Dependencies

- V1 complete (basic entry system)
- Location data populated

## Success Criteria

- Map loads all entries with locations
- Marker clustering works smoothly
- Clicking marker navigates to correct entry
- Performance acceptable with 500+ entries
