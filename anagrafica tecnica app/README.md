# Anagrafica Tecnica Mobile App

iOS application for field-based technical asset surveys with offline-first architecture.

## Project Status

Status: Planning and setup
Target Platform: iOS 16+
Language: Swift
UI Framework: SwiftUI
Roadmap: capability-based (no fixed timeline)

## Key Documents

- Product requirements: `../product-specs.md`
- Mobile UI specs: `mobile-ui-specs.md`

## Technical Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Minimum iOS | 16.0 | Modern SwiftUI support with strong device coverage |
| Storage | Core Data | Native, mature, good for complex relationships |
| Networking | URLSession | Native, supports background tasks |
| Project Structure | SwiftPM modules | Clear boundaries, faster builds, test isolation |
| Floorplan Renderer | Custom vector tile renderer | Best fidelity to DWG output and offline control |
| Sync Retry | Exponential backoff (cap at 5 minutes) | Network-friendly and battery-aware |
| ID Strategy | UUIDv7 | Time-sortable, globally unique |
| Photo Format | JPEG (1280px, 0.8 quality) | Consistent compression and portability |
| Project State Mapping | Hybrid | UI uses Online/Open/Completed mapped to READY/ACTIVE/COMPLETED |

## Project Structure (SwiftPM Modules)

```
anagrafica tecnica app/
├── App/                       # iOS app target
├── Packages/
│   ├── Core/                  # Models, persistence, networking, services, sync
│   ├── DesignSystem/          # Reusable UI components
│   └── Features/
│       ├── Projects/
│       ├── Floorplan/
│       ├── AddAssetWizard/
│       ├── Room/
│       ├── SurveyReport/
│       └── Export/
└── mobile-ui-specs.md
```

Package definition: `Packages/Package.swift` (add as a local package in Xcode).

Each SwiftPM module should include:
- Source code
- Tests (target >=80% coverage)
- README.md and CHANGELOG.md
- Module-specific assets (if any)

## Roadmap (Capability-Based Phases)

1. Foundation (Core)
   - Data models, Core Data schema, networking, core services
2. Core UI (DesignSystem + Features)
   - Projects UI, floorplan renderer, navigation shell
3. Asset Management (AddAssetWizard)
   - Wizard flow, type branching, instance form, photos
4. Room Management (Room)
   - Room view, instance editor, type editor, room notes
5. Survey Hub and Export (SurveyReport + Export)
   - Rooms list, types list, filters, export share sheet
6. Synchronization (Core/Sync)
   - Event log upload, photo upload, exponential backoff
7. Hardening and QA (App + Modules)
   - Validation, error handling, performance, QA pass

## Milestones (Order Only)

1. Data layer complete
2. Navigation working
3. Asset creation end-to-end (local data)
4. Asset editing and room notes
5. Survey hub and filters
6. Sync integration
7. Production readiness

## Offline-First And Sync

- All changes recorded locally as events.
- Photo uploads queued and retried automatically.
- Sync uses exponential backoff with jitter, capped at 5 minutes.
- No manual sync trigger.
- Sync integration happens in Phase 6.

## Development Workflow

1. Select a phase based on dependencies and progress
2. Implement within SwiftPM modules
3. Write tests for new code (target >=80% coverage)
4. Update module README and CHANGELOG
5. Pass phase gate before proceeding

## Testing Requirements

- Unit tests: >=80% coverage
- UI tests: critical user flows
- Integration tests: sync, API, storage
- Performance tests: large datasets
- Snapshot tests: UI regression prevention

## Risks To Track

- Floorplan rendering performance
- Photo upload reliability
- Offline sync conflict handling

## Getting Started

Prerequisites:
- macOS 13.0 or later
- Xcode 15.0 or later
- iOS 16.0+ target device or simulator
- Swift 5.9+

Setup:
1. Review `../product-specs.md` and `mobile-ui-specs.md`
2. Open the Xcode project:
   - `open "anagrafica tecnica app.xcodeproj"`
3. Start with Phase 1 (Foundation)

## Contributing

Code Standards:
- Follow Swift API Design Guidelines
- Use SwiftLint for consistency
- Keep functions small and focused
- Add comments only where needed for complex logic

Pull Request Process:
1. Create a feature branch from `main`
2. Implement functionality with tests
3. Update module README/CHANGELOG
4. Ensure all tests pass
5. Request code review
6. Merge after approval

Commit Message Format:

```
[Phase] Component: Description

Example:
[Phase1] DataModels: Add Instance model with validation
[Phase3] PhotoCapture: Implement JPEG compression
[Phase7] Testing: Add UI tests for Add Asset flow
```
