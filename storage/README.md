# Storage

File storage for DWG files, plan tiles, photos, and exports.

## Structure

### `/dwg-files`
Original DWG floorplan files uploaded by admins.

### `/plan-tiles`
Vector tiles generated from DWG files:
- Clipped per level
- Optimized for mobile app consumption
- Background visualization for Architecture layer

### `/photos`
Asset photos captured in the field:
- Format: JPEG, 1280px longest edge, quality 0.8
- Naming: `{project_uuid_short}_{operator_id}_{timestamp}_{sequence}`
- Photos retain capture-time names throughout system
- Target: Up to 1,000,000 photos/year

### `/exports`
Generated export packages:
- CSV/Excel files with asset data
- Photo packages (zipped collections)
- Summary reports

## Technology

Recommended: AWS S3 / Google Cloud Storage / Azure Blob Storage

Optional CDN (CloudFront / Cloud CDN) for fast plan tile delivery to mobile app.

## Photo Management

- Photos named at capture time with globally unique identifiers
- Same name used internally and in client exports
- No renaming or transformation of photo files
- Background upload queue from mobile devices
