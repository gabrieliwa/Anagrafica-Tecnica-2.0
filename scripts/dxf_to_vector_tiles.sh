#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  dxf_to_vector_tiles.sh <input.dxf> <output_dir>

Example:
  bash scripts/dxf_to_vector_tiles.sh "anagrafica tecnica app/demo_plans.dxf" "anagrafica tecnica app/demo_plan_output"

Note:
  This script outputs GeoJSON-only demo data (no tiles). The name is legacy.

Dependencies:
  - ogr2ogr, ogrinfo (GDAL)
  - python3
  - mapshaper (optional, used for geometry cleanup)
USAGE
}

if [[ $# -lt 2 ]]; then
  usage
  exit 1
fi

DXF="$1"
OUT_DIR="$2"

if [[ ! -f "$DXF" ]]; then
  echo "Error: DXF not found: $DXF" >&2
  exit 1
fi

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: missing dependency: $1" >&2
    exit 1
  fi
}

require_cmd ogr2ogr
require_cmd ogrinfo
require_cmd python3

HAS_MAPSHAPER=0
if command -v mapshaper >/dev/null 2>&1; then
  HAS_MAPSHAPER=1
fi

WORK_DIR="$OUT_DIR/_work"
mkdir -p "$WORK_DIR"

echo "Exporting layers to GeoJSON..."
export_layer() {
  local layer_name="$1"
  local out_file="$2"
  ogr2ogr -f GeoJSON -skipfailures -where "Layer='${layer_name}'" "$out_file" "$DXF" entities
}

export_layer "1_ROOMS" "$WORK_DIR/rooms_raw.geojson"
export_layer "2_LEVEL" "$WORK_DIR/levels_raw.geojson"
export_layer "3_NORTH" "$WORK_DIR/north_raw.geojson"
export_layer "0" "$WORK_DIR/background_raw.geojson"

has_features() {
  python3 - <<'PY'
import json
import os
import sys

path = os.environ["CHECK_FILE"]
try:
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    if data.get("features"):
        sys.exit(0)
    sys.exit(1)
except FileNotFoundError:
    sys.exit(1)
PY
}

export CHECK_FILE="$WORK_DIR/levels_raw.geojson"
if ! has_features; then
  export_layer "2_LEVELS" "$WORK_DIR/levels_raw.geojson"
fi

export WORK_DIR
python3 - <<'PY'
import json
import os

work_dir = os.environ["WORK_DIR"]
files = {
    "1_ROOMS": os.path.join(work_dir, "rooms_raw.geojson"),
    "2_LEVEL": os.path.join(work_dir, "levels_raw.geojson"),
    "3_NORTH": os.path.join(work_dir, "north_raw.geojson"),
    "0": os.path.join(work_dir, "background_raw.geojson"),
}

missing = []
for layer, path in files.items():
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        if not data.get("features"):
            missing.append(layer)
    except FileNotFoundError:
        missing.append(layer)

if missing:
    msg = ", ".join(missing)
    raise SystemExit(f"Error: required DXF layers have no features: {msg}")
PY

if [[ "$HAS_MAPSHAPER" -eq 1 ]]; then
  echo "Cleaning geometry with mapshaper..."
  mapshaper "$WORK_DIR/rooms_raw.geojson" -clean -o "$WORK_DIR/rooms_clean.geojson"
  mapshaper "$WORK_DIR/levels_raw.geojson" -clean -o "$WORK_DIR/levels_clean.geojson"
  mapshaper "$WORK_DIR/north_raw.geojson" -clean -o "$WORK_DIR/north_clean.geojson"
  mapshaper "$WORK_DIR/background_raw.geojson" -clean -o "$WORK_DIR/background_clean.geojson"
else
  echo "Warning: mapshaper not found; skipping geometry cleanup." >&2
  cp "$WORK_DIR/rooms_raw.geojson" "$WORK_DIR/rooms_clean.geojson"
  cp "$WORK_DIR/levels_raw.geojson" "$WORK_DIR/levels_clean.geojson"
  cp "$WORK_DIR/north_raw.geojson" "$WORK_DIR/north_clean.geojson"
  cp "$WORK_DIR/background_raw.geojson" "$WORK_DIR/background_clean.geojson"
fi

export ROOMS_GEOJSON="$WORK_DIR/rooms_clean.geojson"
export LEVELS_GEOJSON="$WORK_DIR/levels_clean.geojson"
export NORTH_GEOJSON="$WORK_DIR/north_clean.geojson"
export BACKGROUND_GEOJSON="$WORK_DIR/background_clean.geojson"
export OUT_DIR

echo "Building plan_template.json and per-level GeoJSON..."
python3 - <<'PY'
import json
import os
import re
import sys

rooms_path = os.environ["ROOMS_GEOJSON"]
levels_path = os.environ["LEVELS_GEOJSON"]
north_path = os.environ["NORTH_GEOJSON"]
background_path = os.environ["BACKGROUND_GEOJSON"]
out_dir = os.environ["OUT_DIR"]

LABEL_KEYS = ("Text", "TEXT", "text", "Label", "label", "Name", "name", "STRING", "String", "string")

def load_geojson(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def save_json(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)

def geom_type(feature):
    return feature.get("geometry", {}).get("type")

def iter_coords(geom):
    gtype = geom.get("type")
    coords = geom.get("coordinates")
    if gtype == "Point":
        yield (coords[0], coords[1])
    elif gtype == "MultiPoint":
        for pt in coords:
            yield (pt[0], pt[1])
    elif gtype == "LineString":
        for pt in coords:
            yield (pt[0], pt[1])
    elif gtype == "MultiLineString":
        for line in coords:
            for pt in line:
                yield (pt[0], pt[1])
    elif gtype == "Polygon":
        for ring in coords:
            for pt in ring:
                yield (pt[0], pt[1])
    elif gtype == "MultiPolygon":
        for poly in coords:
            for ring in poly:
                for pt in ring:
                    yield (pt[0], pt[1])

def bounds_for_geom(geom):
    xs = []
    ys = []
    for x, y in iter_coords(geom):
        xs.append(x)
        ys.append(y)
    if not xs:
        return None
    return [min(xs), min(ys), max(xs), max(ys)]

def representative_point(feature):
    geom = feature["geometry"]
    gtype = geom["type"]
    coords = geom["coordinates"]
    if gtype == "Point":
        return [coords[0], coords[1]]
    if gtype == "MultiPoint":
        return [coords[0][0], coords[0][1]]
    if gtype == "LineString":
        return [coords[0][0], coords[0][1]]
    if gtype == "MultiLineString":
        return [coords[0][0][0], coords[0][0][1]]
    if gtype == "Polygon":
        return [coords[0][0][0], coords[0][0][1]]
    if gtype == "MultiPolygon":
        return [coords[0][0][0][0], coords[0][0][0][1]]
    return None

def is_ring(coords):
    return bool(coords) and coords[0] == coords[-1]

def feature_as_polygon(feature):
    geom = feature.get("geometry") or {}
    gtype = geom.get("type")
    coords = geom.get("coordinates")
    if gtype in ("Polygon", "MultiPolygon"):
        return feature
    if gtype == "LineString" and is_ring(coords):
        return {
            "type": "Feature",
            "properties": feature.get("properties", {}),
            "geometry": {"type": "Polygon", "coordinates": [coords]},
        }
    if gtype == "MultiLineString" and coords and len(coords) == 1 and is_ring(coords[0]):
        return {
            "type": "Feature",
            "properties": feature.get("properties", {}),
            "geometry": {"type": "Polygon", "coordinates": [coords[0]]},
        }
    return None

def point_in_ring(point, ring):
    x, y = point
    inside = False
    n = len(ring)
    if n < 3:
        return False
    for i in range(n):
        x1, y1 = ring[i][0], ring[i][1]
        x2, y2 = ring[(i + 1) % n][0], ring[(i + 1) % n][1]
        if (y1 > y) != (y2 > y):
            x_int = x1 + (y - y1) * (x2 - x1) / (y2 - y1)
            if x_int >= x:
                inside = not inside
    return inside

def point_in_polygon(point, polygon):
    if not polygon:
        return False
    outer = polygon[0]
    if not point_in_ring(point, outer):
        return False
    for hole in polygon[1:]:
        if point_in_ring(point, hole):
            return False
    return True

def point_in_geom(point, geom):
    gtype = geom["type"]
    coords = geom["coordinates"]
    if gtype == "Polygon":
        return point_in_polygon(point, coords)
    if gtype == "MultiPolygon":
        return any(point_in_polygon(point, poly) for poly in coords)
    return False

def get_label_text(props):
    if not props:
        return None
    for key in LABEL_KEYS:
        val = props.get(key)
        if val is None:
            continue
        text = str(val).strip()
        if text:
            return text
    return None

def find_label_for_polygon(poly_feature, label_points):
    geom = poly_feature["geometry"]
    for label in label_points:
        if point_in_geom(label["point"], geom):
            return label["text"]
    return None

def normalize_label(label_text):
    if not label_text:
        return None
    text = re.sub(r"\s+", " ", label_text).strip()
    return text if text else None

def centroid_of_polygon(coords):
    ring = coords[0]
    if len(ring) < 3:
        return [ring[0][0], ring[0][1]]
    area = 0.0
    cx = 0.0
    cy = 0.0
    n = len(ring)
    for i in range(n):
        x1, y1 = ring[i][0], ring[i][1]
        x2, y2 = ring[(i + 1) % n][0], ring[(i + 1) % n][1]
        cross = x1 * y2 - x2 * y1
        area += cross
        cx += (x1 + x2) * cross
        cy += (y1 + y2) * cross
    if area == 0.0:
        return [ring[0][0], ring[0][1]]
    area *= 0.5
    cx /= (6.0 * area)
    cy /= (6.0 * area)
    return [cx, cy]

def strip_z_ring(ring):
    return [[pt[0], pt[1]] for pt in ring]

def ring_area(ring):
    if len(ring) < 3:
        return 0.0
    area = 0.0
    for i in range(len(ring)):
        x1, y1 = ring[i][0], ring[i][1]
        x2, y2 = ring[(i + 1) % len(ring)][0], ring[(i + 1) % len(ring)][1]
        area += x1 * y2 - x2 * y1
    return area / 2.0

def orient_ring(ring, clockwise):
    if not ring:
        return ring
    area = ring_area(ring)
    if area == 0.0:
        return ring
    is_cw = area < 0.0
    if is_cw != clockwise:
        return list(reversed(ring))
    return ring

def orient_polygon_coords(coords):
    if not coords:
        return coords
    outer = orient_ring(coords[0], clockwise=False)
    holes = [orient_ring(hole, clockwise=True) for hole in coords[1:]]
    return [outer] + holes

def normalize_polygon_geometry(geom):
    gtype = geom.get("type")
    coords = geom.get("coordinates")
    if gtype == "Polygon":
        return {"type": "Polygon", "coordinates": orient_polygon_coords(coords)}
    if gtype == "MultiPolygon":
        return {"type": "MultiPolygon", "coordinates": [orient_polygon_coords(poly) for poly in coords]}
    return geom

def normalize_polygon_feature(feature):
    geom = feature.get("geometry") or {}
    if geom.get("type") not in ("Polygon", "MultiPolygon"):
        return feature
    normalized = normalize_polygon_geometry(geom)
    if normalized is geom:
        return feature
    updated = dict(feature)
    updated["geometry"] = normalized
    return updated

rooms_raw = load_geojson(rooms_path)
levels_raw = load_geojson(levels_path)
north_raw = load_geojson(north_path)
background_raw = load_geojson(background_path)

room_polys = []
for f in rooms_raw["features"]:
    poly = feature_as_polygon(f)
    if poly:
        room_polys.append(normalize_polygon_feature(poly))
room_label_points = []
for f in rooms_raw["features"]:
    if geom_type(f) in ("Point", "MultiPoint"):
        for pt in iter_coords(f["geometry"]):
            text = get_label_text(f.get("properties", {}))
            if text:
                room_label_points.append({"point": pt, "text": text})

level_polys = []
for f in levels_raw["features"]:
    poly = feature_as_polygon(f)
    if poly:
        level_polys.append(normalize_polygon_feature(poly))
level_label_points = []
for f in levels_raw["features"]:
    if geom_type(f) in ("Point", "MultiPoint"):
        for pt in iter_coords(f["geometry"]):
            text = get_label_text(f.get("properties", {}))
            if text:
                level_label_points.append({"point": pt, "text": text})

north_lines = [f for f in north_raw["features"] if geom_type(f) in ("LineString", "MultiLineString")]
background_lines = [f for f in background_raw["features"] if geom_type(f) in ("LineString", "MultiLineString", "Polygon", "MultiPolygon")]

levels = []
for idx, poly in enumerate(level_polys):
    label = find_label_for_polygon(poly, level_label_points)
    geom = poly["geometry"]
    bounds = bounds_for_geom(geom)
    centroid = None
    if geom["type"] == "Polygon":
        centroid = centroid_of_polygon(geom["coordinates"])
    elif geom["type"] == "MultiPolygon":
        centroid = centroid_of_polygon(geom["coordinates"][0])
    levels.append({
        "poly": poly,
        "label": label,
        "bounds": bounds,
        "centroid": centroid,
        "rooms": [],
        "north": None,
        "background": [],
        "index": None,
        "id": None,
    })

def find_level_for_point(point):
    for level in levels:
        if point_in_geom(point, level["poly"]["geometry"]):
            return level
    return None

room_errors = []
for poly in room_polys:
    label = normalize_label(find_label_for_polygon(poly, room_label_points))
    bounds = bounds_for_geom(poly["geometry"])
    if bounds is None:
        room_errors.append("<room with empty geometry>")
        continue
    room = {
        "label": label,
        "geometry": poly["geometry"],
        "bounds": bounds,
    }
    pt = representative_point(poly)
    level = find_level_for_point(pt)
    if level is None:
        room_errors.append(label or "<room without level>")
        continue
    level["rooms"].append(room)

if room_errors:
    err_sample = ", ".join(room_errors[:5])
    raise SystemExit(f"Room level assignment errors: {err_sample}")

for line in north_lines:
    coords = line["geometry"]["coordinates"]
    start = coords[0] if line["geometry"]["type"] == "LineString" else coords[0][0]
    end = coords[-1] if line["geometry"]["type"] == "LineString" else coords[0][-1]
    start = [start[0], start[1]]
    end = [end[0], end[1]]
    level = find_level_for_point(start)
    if level:
        level["north"] = {"start": start, "end": end}

for feature in background_lines:
    pt = representative_point(feature)
    if not pt:
        continue
    level = find_level_for_point(pt)
    if level:
        level["background"].append(normalize_polygon_feature(feature))

used_indexes = set()
for level in levels:
    if level["index"] is not None:
        continue
    if level["label"]:
        match = re.search(r"\b(\d+)\b", level["label"])
        if match:
            idx = int(match.group(1))
            if idx not in used_indexes:
                level["index"] = idx
                used_indexes.add(idx)

remaining = [lvl for lvl in levels if lvl["index"] is None]
remaining.sort(key=lambda l: (l["centroid"][1] if l["centroid"] else 0.0))
next_idx = 0
for level in remaining:
    while next_idx in used_indexes:
        next_idx += 1
    level["index"] = next_idx
    used_indexes.add(next_idx)
    next_idx += 1

def room_sort_key(room):
    min_x, min_y, max_x, max_y = room["bounds"]
    return (-max_y, min_x, max_x, min_y)

for level in levels:
    rooms_sorted = sorted(level["rooms"], key=room_sort_key)
    for seq, room in enumerate(rooms_sorted, start=1):
        number = f"{level['index']}{seq:03d}"
        room["number"] = number
        room["id"] = f"R{number}"
        room["name"] = room.get("label") or f"Room {number}"
    level["rooms"] = rooms_sorted

levels.sort(key=lambda l: l["index"])
for level in levels:
    level_id = f"L{level['index']}"
    level["id"] = level_id
    level_name = level["label"] or f"Level {level['index']}"
    level_dir = os.path.join(out_dir, "levels", level_id)
    os.makedirs(level_dir, exist_ok=True)
    save_json(os.path.join(level_dir, "background.geojson"), {
        "type": "FeatureCollection",
        "features": level["background"],
    })
    save_json(os.path.join(level_dir, "rooms.geojson"), {
        "type": "FeatureCollection",
        "features": [
            {
                "type": "Feature",
                "geometry": room["geometry"],
                "properties": {
                    "id": room["id"],
                    "number": room["number"],
                    "name": room["name"],
                },
            }
            for room in level["rooms"]
        ],
    })
    if level["north"]:
        save_json(os.path.join(level_dir, "north.json"), level["north"])
    level["name"] = level_name

plan = {"levels": []}
for level in levels:
    rooms_out = []
    for room in sorted(level["rooms"], key=lambda r: r["number"]):
        geom = room["geometry"]
        if geom["type"] == "Polygon":
            ring = strip_z_ring(geom["coordinates"][0])
        elif geom["type"] == "MultiPolygon":
            ring = strip_z_ring(geom["coordinates"][0][0])
        else:
            continue
        rooms_out.append({
            "id": room["id"],
            "number": room["number"],
            "name": room["name"],
            "shape": {"polygon": ring},
        })
    plan["levels"].append({
        "id": level["id"],
        "index": level["index"],
        "name": level["name"],
        "background": {
            "geojson": f"levels/{level['id']}/background.geojson",
            "bounds": level["bounds"],
        },
        "north": level["north"],
        "rooms": rooms_out,
    })

save_json(os.path.join(out_dir, "plan_template.json"), plan)
PY

echo "Done."
echo "Plan template: $OUT_DIR/plan_template.json"
