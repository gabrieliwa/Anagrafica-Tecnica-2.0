# Demo DXF Conversion (Vector Tiles + Tappable Rooms)

This guide explains how to convert a DXF floorplan into vector tiles and a `plan_template.json` file for the demo project.

## Requirements

DXF layer structure (exact names):
- `0` - Background linework (walls, doors, windows). Render-only.
- `1_ROOMS` - Closed room boundary polygons. Room labels are optional.
- `2_LEVEL` - Closed level boundary polygons + level label text inside each level.
- `3_NORTH` - One line segment per level. Start point inside the level boundary; direction indicates north.

Closed polylines are accepted; the script will convert them into polygons during import.

Room labels (optional):
- If present, label text is used as the room name only.
- Room numbers are auto-assigned by the script using spatial order (top-left to bottom-right).
- Ordering uses plan-space coordinates (higher Y = top, lower X = left).

## Dependencies

Install these tools:
- GDAL (`ogr2ogr`, `ogrinfo`)
- tippecanoe
- python3
- mapshaper (optional but recommended for cleanup)

## How the script reads layers

GDAL's DXF driver exposes a single `entities` layer. The script filters that layer by the `Layer` attribute to split out:
`0`, `1_ROOMS`, `2_LEVEL`, `3_NORTH`.

## Usage

From the repo root:
```bash
bash scripts/dxf_to_vector_tiles.sh "anagrafica tecnica app/demo_plans.dxf" "anagrafica tecnica app/demo_plan_output"
```

Optional environment overrides:
```bash
MIN_ZOOM=14 MAX_ZOOM=16 TILE_SIZE=512 EXTENT=4096 \
bash scripts/dxf_to_vector_tiles.sh input.dxf output_dir
```

For demos, keep `MAX_ZOOM` at 16 (or lower) to avoid generating multi-gigabyte tile sets.

## Output

```
demo_plan_output/
  plan_template.json
  levels/
    L0/
      background.geojson
      rooms.geojson
      north.json
      tiles/{z}/{x}/{y}.pbf
    L1/
      ...
  _work/                 # intermediate GeoJSON
```

`plan_template.json` contains:
- Levels with `background.vector_tiles` pointing to tiles
- Tappable room polygons with room number and name
- Per-level north vectors and bounds

## App Integration (What To Keep + Where To Put It)

Required files for the app:
- `plan_template.json`
- `levels/<LEVEL_ID>/tiles/{z}/{x}/{y}.pbf` (vector tiles)

Optional (debug only):
- `levels/<LEVEL_ID>/rooms.geojson`, `background.geojson`, `north.json`
- `_work/` folder

Where to place them (so the app can load them as bundled demo data):
1. Create this folder in the app target if it doesn't exist:
   `anagrafica tecnica app/AnagraficaTecnica/AnagraficaTecnica/Resources/DemoPlan`
2. Copy into it:
   - `plan_template.json`
   - the full `levels/` directory (keep the tile folder structure intact)
3. In Xcode, add `Resources/DemoPlan` as a **folder reference** to preserve the tiles subfolders.

Example final layout:
```
anagrafica tecnica app/AnagraficaTecnica/AnagraficaTecnica/Resources/DemoPlan/
  plan_template.json
  levels/
    L0/tiles/{z}/{x}/{y}.pbf
    L1/tiles/{z}/{x}/{y}.pbf
```

## Troubleshooting

- **Missing layers**: Check DXF layer names match exactly (`0`, `1_ROOMS`, `2_LEVEL`, `3_NORTH`).
- **Level layer mismatch**: The script also accepts `2_LEVELS` if your file uses that name, but `2_LEVEL` is the required standard.
- **Room names missing**: Room labels are optional. If none are provided, the script assigns default names.
- **Room not assigned to a level**: Room polygon must be fully inside a level boundary.
- **No tiles generated**: Check that `tippecanoe` is installed and that background features exist on layer `0`.

## Notes

- The script assumes plan-space coordinates and uses those directly for tiles.
- Use `plan_template.json` as the plan section in your demo project template file (see `anagrafica tecnica app/DEMO-PROJECT-TEMPLATE-GUIDE.md`).
