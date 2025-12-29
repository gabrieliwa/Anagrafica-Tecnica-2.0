# Admin Dashboard

Browser-based control panel for project administrators.

## Responsibilities

### Project Management
- Create and configure new projects
- Upload and validate DWG files
- Upload asset/parameter catalogues
- Bind schema versions to projects

### Monitoring
- Track survey progress by level and room
- Monitor data quality (missing recommended fields, anomalies)
- View room lifecycle states (Empty, Complete, Approved)

### Export & Approval
- Approve projects for export
- Generate client deliverables (CSV/Excel + photos)
- Download summary reports

## Technology Stack

Recommended: React or Vue.js with TypeScript and Tailwind CSS

## Folder Structure

- `/src/components` - Reusable UI components
- `/src/pages` - Main application pages
- `/src/services` - API communication layer
- `/src/hooks` - Custom React hooks
- `/src/utils` - Utility functions
- `/public` - Static assets
