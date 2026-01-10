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
- Initial load starts at the lowest level by name (S#/B# below ground, PT/G at ground, P# above); switching levels resets zoom/pan to fit.
- Empty rooms render gray with a (+); occupied rooms render light blue with a count badge (assets + room notes).
- Tapping a room with items opens Room View; empty rooms launch Add Asset Wizard.
- Read-only mode behavior is deferred until sync is implemented.
