# Demo Project Template Guide

This guide explains how to create a demo project template file for the mobile app. It covers:
- A plan created from a DXF file structured per `product-specs.md`, exported as vector tiles
- Asset families and parameters using a simple, readable schema

The output is a single template file (YAML or JSON) you can load into the app as demo data.

---

## Part A — Plan Template From DXF

### Step 1: Prepare the DXF

Follow the floorplan rules in `product-specs.md`:
- Each level must have a closed boundary.
- Rooms are closed regions fully inside their level boundary.
- Room labels (optional) must be inside the room region.
- Room numbers are auto-assigned (top-left to bottom-right per level) and use 4 digits: first digit is the floor index (lowest floor = 0), last three are sequential within the floor (e.g., 2001).
- Keep everything in a consistent "Plan Space" coordinate system.

**Required Layer Names (exact):**
- `0` — Walls, doors, windows (background only, not semantically parsed)
- `1_ROOMS` — Closed room boundary polygons + optional room label text inside each room
- `2_LEVEL` — Closed level boundary polygons + level label text inside each level
- `3_NORTH` — One line segment per level, start point inside the level boundary

**Room labels (optional):**
- If present, label text is used as the room name only.
- Room numbers are auto-assigned by the import script using spatial order (top-left to bottom-right).

### Step 2: Clean layers (single file)

Keep a single DXF with multiple levels and ensure the required layers are correct:
- Keep geometry on the correct layers (`0`, `1_ROOMS`, `2_LEVEL`, `3_NORTH`).
- Ensure every room is a closed polyline (no gaps).
- Room label text is optional; if present, it becomes the room name.
- Remove decorative details that are not needed for the demo.

### Step 3: Export vector geometry

Convert each level to vector features in the same plan-space coordinates:
- Export rooms as polygons and labels as point features.
- Export walls/doors as line features for rendering.
- Preserve coordinates exactly (no scaling or rotation).

Use the conversion script in `scripts/` to do this automatically (see below).

### Step 4: Generate vector tiles (MVT)

Create a tile set per level for the vector background:
- Build tiles from walls/labels (and optional room outlines).
- Keep the room polygons in the template for tap detection.
- Record min/max zoom, tile size, and bounds for the renderer.

The script outputs per-level tiles into `levels/<LEVEL_ID>/tiles/{z}/{x}/{y}.pbf`.

### Step 5: Build tappable rooms data

The app should use the room polygons (not the vector background) for hit testing:
- Each room polygon becomes a room record in the template.
- Join label text to polygons if labels are separate (spatial join).
- Ensure `room.name` is filled when label text exists; numbering is auto-assigned by the script.

### Step 6: Run the conversion script

From the repo root:
```bash
bash scripts/dxf_to_vector_tiles.sh "anagrafica tecnica app/demo_plans.dxf" "anagrafica tecnica app/demo_plan_output"
```

The script generates:
- Vector tiles per level
- A `plan_template.json` file with levels and tappable rooms
- Debug GeoJSON files under `demo_plan_output/_work/`

For full usage details, see `scripts/DEMO-DXF-CONVERSION.md`.

### Step 7: Define levels and rooms in the template

For each level, include:
- `id`, `index`, `name`
- `background` (vector tile path + metadata)
- `rooms` list with `id`, `number`, `name`, and a polygon in plan space

### Step 8: Sanity checks

- Every room polygon is inside its level boundary.
- Room numbers are unique across the project.
- First digit of room number matches the level index.
- Room name and number exist for each room.

---

## Part B — Asset Families and Parameters

### Step 1: Choose families

Pick 3–6 families that reflect the demo domain (e.g., Lighting, HVAC, Electrical, Network).

### Step 2: Define parameters per family

Parameters are defined at the Family level and scoped to:
- `type_parameters`: shared across all instances of a Type
- `instance_parameters`: per-asset fields

Each parameter should include:
- `key` (stable identifier)
- `label` (UI label)
- `type` (text, number, enum, boolean, date)
- `required` (true/false)
- Optional `unit` for numbers
- `values` for enum parameters

### Step 3: Photo rules and Room Note

From `product-specs.md`:
- Type photo: exactly 1 required
- Instance photos: optional, up to 5
- Room Note: 1 required photo + up to 4 optional
- Room Note flags are mutually exclusive (`empty_room` vs `room_blocked`)
- If `room_blocked` is true, a description is required

### Step 4: (Optional) Seed Types and Instances

If you want a more realistic demo:
- Add 1–3 Types per family
- Add 2–5 Instances per Type, each linked to a room
- Use consistent Type naming to test fuzzy matching behavior

---

## Suggested Template Structure (YAML)

```yaml
project:
  id: "demo-001"
  name: "Demo Facility"
  state: "READY"

levels:
  - id: "L0"
    index: 0
    name: "Ground"
    background:
      vector_tiles:
        tiles: "levels/L0/tiles/{z}/{x}/{y}.pbf"
        min_zoom: 14
        max_zoom: 20
        tile_size: 512
        extent: 4096
        bounds: [0,0,2400,1400]
    rooms:
      - id: "R0001"
        number: "0001"
        name: "Lobby"
        shape:
          polygon: [[120,180],[640,180],[640,520],[120,520]]
      - id: "R0002"
        number: "0002"
        name: "Electrical Room"
        shape:
          polygon: [[700,180],[980,180],[980,520],[700,520]]

families:
  - name: "Lighting"
    type_parameters:
      - key: "manufacturer"
        label: "Manufacturer"
        type: "text"
        required: true
      - key: "model"
        label: "Model"
        type: "text"
        required: true
      - key: "wattage"
        label: "Wattage"
        type: "number"
        unit: "W"
        required: true
      - key: "mount_type"
        label: "Mount Type"
        type: "enum"
        values: ["Ceiling","Wall","Suspended"]
        required: true
    instance_parameters:
      - key: "condition"
        label: "Condition"
        type: "enum"
        values: ["New","Good","Worn","Damaged"]
        required: true
      - key: "serial_number"
        label: "Serial Number"
        type: "text"
        required: false

room_note:
  parameters:
    - key: "empty_room"
      label: "Empty room"
      type: "boolean"
      required: false
    - key: "room_blocked"
      label: "Room is blocked"
      type: "boolean"
      required: false
    - key: "description"
      label: "Description"
      type: "text"
      required: false
  rules:
    mutually_exclusive: ["empty_room","room_blocked"]
    required_if:
      room_blocked: ["description"]

photo_rules:
  type: { min: 1, max: 1 }
  instance: { min: 0, max: 5 }
  room_note: { min: 1, max: 5 }

seed:
  types:
    - id: "T-LGT-001"
      family: "Lighting"
      name: "Philips 30W LED Panel"
      parameters:
        manufacturer: "Philips"
        model: "LED-30"
        wattage: 30
        mount_type: "Ceiling"
  instances:
    - id: "I-LGT-0001"
      type: "T-LGT-001"
      room: "R0001"
      parameters:
        condition: "Good"
        serial_number: "SN-0001"
```

---

## Notes for later backend integration

- The demo template is local-only; it mirrors the Family → Type → Instance model in `product-specs.md`.
- Assets are linked to rooms only (no X/Y coordinates).
- When backend sync is introduced, IDs should be switched to UUIDv7 per `README.md`.
