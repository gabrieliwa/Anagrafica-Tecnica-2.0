# Floorplan

Purpose: Vector tile renderer, room selection, level picker.

Dependencies:
- Core
- DesignSystem

Notes:
- Keep module boundaries strict and avoid cross-feature coupling.
- Zoom out is capped to the full-plan fit; zoom in is capped by the smallest room size.
- Room badges (+ / counts) render at a constant on-screen size during zoom.
- Zoom is anchored to the view center.
