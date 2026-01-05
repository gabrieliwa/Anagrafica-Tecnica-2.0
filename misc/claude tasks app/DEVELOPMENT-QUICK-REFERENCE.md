# Development Quick Reference

## Phase Overview

| Phase | Duration | Sprints | Dependencies | Status |
|-------|----------|---------|--------------|--------|
| **1. Foundation** | 4 weeks | 1-2 | None | Not Started |
| **2. Core UI** | 4 weeks | 3-4 | Phase 1 | Not Started |
| **3. Asset Management** | 6 weeks | 5-7 | Phases 1-2 | Not Started |
| **4. Room Management** | 4 weeks | 8-9 | Phases 1-3 | Not Started |
| **5. Survey Reporting** | 4 weeks | 10-11 | Phases 1-4 | Not Started |
| **6. Synchronization** | 4 weeks | 12-13 | Phases 1-5 | Not Started |
| **7. Polish** | 2 weeks | 14 | All phases | Not Started |
| **TOTAL** | **28 weeks** | **14 sprints** | | |

## Dependency Graph

```
Phase 1: Foundation
    │
    ├──────────────────────────────────────────────────┐
    │                                                   │
    ▼                                                   ▼
Phase 2: Core UI                              Phase 3: Asset Management
    │                                                   │
    │                   ┌───────────────────────────────┘
    │                   │
    ▼                   ▼
Phase 4: Room Management
    │
    ▼
Phase 5: Survey Reporting
    │
    ▼
Phase 6: Synchronization
    │
    ▼
Phase 7: Polish
```

## Critical Path

The critical path for MVP delivery:

1. **Foundation** (4 weeks) - Cannot start anything else without this
2. **Core UI** (4 weeks) - Basic app structure
3. **Asset Management** (6 weeks) - Core functionality
4. **Synchronization** (4 weeks) - Backend integration
5. **Polish** (2 weeks) - Production ready

**Minimum viable timeline:** ~20 weeks (5 months)

**Full feature timeline:** 28 weeks (7 months)

## Parallel Development Opportunities

### After Phase 1 Complete:
- **Team A:** Core UI (Phase 2)
- **Team B:** Asset Management (Phase 3)

### After Phase 3 Complete:
- **Team A:** Room Management (Phase 4)
- **Team B:** Survey Reporting (Phase 5)

### After Phase 5 Complete:
- **Team A:** Synchronization (Phase 6)
- **Team B:** Testing & Polish setup (Phase 7)

**With 2 teams:** ~20 weeks (5 months)

## Component Checklist

### Phase 1: Foundation ✓/✗
- [ ] DataModels/
- [ ] LocalStorage/
- [ ] NetworkLayer/
- [ ] CoreServices/

### Phase 2: Core UI ✓/✗
- [ ] ProjectsList/
- [ ] FloorplanViewer/
- [ ] CommonComponents/
- [ ] Navigation/

### Phase 3: Asset Management ✓/✗
- [ ] AddAssetWizard/
- [ ] FamilySelection/
- [ ] TypeSelection/
- [ ] InstanceForm/
- [ ] PhotoCapture/

### Phase 4: Room Management ✓/✗
- [ ] RoomView/
- [ ] InstanceEditor/
- [ ] TypeEditor/
- [ ] RoomNotes/

### Phase 5: Survey Reporting ✓/✗
- [ ] SurveyReportHub/
- [ ] RoomsList/
- [ ] TypesList/
- [ ] ProjectExport/

### Phase 6: Synchronization ✓/✗
- [ ] SyncEngine/
- [ ] EventSourcing/
- [ ] PhotoUploadQueue/
- [ ] SurveyCompletion/

### Phase 7: Polish ✓/✗
- [ ] ReadOnlyMode/
- [ ] ErrorHandling/
- [ ] Testing/
- [ ] Performance/

## Key Milestones

| Milestone | Description | Week | Phase |
|-----------|-------------|------|-------|
| **M1: Data Layer Complete** | Models, storage, API client working | 4 | 1 |
| **M2: Navigation Working** | Can navigate between screens | 8 | 2 |
| **M3: Can Add Assets** | Complete asset creation workflow | 14 | 3 |
| **M4: Can Edit Assets** | Can modify existing assets | 18 | 4 |
| **M5: Survey Report Working** | Can view and filter all data | 22 | 5 |
| **M6: Sync Working** | Data flows to backend | 26 | 6 |
| **M7: Production Ready** | Polished, tested, deployable | 28 | 7 |

## Testing Gates

Each phase must pass its testing gate before the next phase begins:

### Phase 1 Gate
- [ ] All data models have unit tests (≥80% coverage)
- [ ] Core Data migrations tested
- [ ] API client integration tests pass
- [ ] Event logging works correctly

### Phase 2 Gate
- [ ] All view models have unit tests (≥80% coverage)
- [ ] Floorplan renders correctly
- [ ] Navigation flows work
- [ ] Snapshot tests capture current UI

### Phase 3 Gate
- [ ] Asset creation flow works end-to-end
- [ ] Photo capture and compression tested
- [ ] Fuzzy matching works correctly
- [ ] All validation rules enforced

### Phase 4 Gate
- [ ] Instance editing works correctly
- [ ] Type editing updates all instances
- [ ] Room Notes work as expected
- [ ] Delete confirmation works

### Phase 5 Gate
- [ ] All lists perform well with 1000+ items
- [ ] Filters work correctly
- [ ] Export generates valid files
- [ ] Search is fast and accurate

### Phase 6 Gate
- [ ] Events upload in correct order
- [ ] Retry logic works correctly
- [ ] Background uploads work
- [ ] Survey completion validation works

### Phase 7 Gate
- [ ] Read-only mode prevents all edits
- [ ] Error handling covers all scenarios
- [ ] Performance benchmarks met
- [ ] No critical bugs remain

## Risk Register

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Floorplan rendering performance** | High | Medium | Early prototyping, tile optimization |
| **Photo upload reliability** | High | Medium | Robust retry logic, background tasks |
| **Offline sync conflicts** | Medium | Low | Event sourcing, careful state management |
| **Large dataset performance** | Medium | Medium | Pagination, lazy loading, profiling |
| **Camera permissions** | Low | High | Clear permission requests, fallbacks |
| **Network reliability** | High | High | Comprehensive retry logic, offline-first |

## Resource Allocation

### Backend Team Requirements
- Phase 1: Define API contracts
- Phase 6: Sync endpoint implementation
- Ongoing: Support and bug fixes

### Design Team Requirements
- Phase 2: UI components and screens
- Phase 3: Wizard flow design
- Phase 7: Final polish and refinements

### QA Team Requirements
- Phase 3+: Begin manual testing
- Phase 6: Sync testing
- Phase 7: Full regression testing

## Technology Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Local Storage** | Core Data | Native, mature, good for complex relationships |
| **Networking** | URLSession | Native, supports background tasks |
| **UI Framework** | SwiftUI | Modern, declarative, less boilerplate |
| **ID Strategy** | UUIDv7 | Time-sortable, globally unique |
| **Photo Format** | JPEG | Excellent compression, universal support |
| **Event Log** | JSON in Core Data | Simple, queryable, inspectable |

## Communication Plan

### Weekly Standups
- Monday: Sprint planning
- Wednesday: Progress check
- Friday: Demo and retrospective

### Phase Gates
- Review meeting at end of each phase
- Go/no-go decision before next phase starts
- Update project plan based on learnings

### Documentation
- README updates as code changes
- Architecture decision records (ADRs)
- Release notes preparation

## Success Metrics

### Development Metrics
- Sprint velocity
- Test coverage
- Code review turnaround
- Bug escape rate

### App Metrics (Post-Launch)
- Crash-free rate (target: >99.9%)
- App launch time (target: <2s)
- Survey completion rate
- Sync success rate (target: >99%)
- User retention

## Next Steps

1. **Review** this strategy with the team
2. **Set up** the Xcode project structure
3. **Create** initial Core Data model
4. **Define** API contracts with backend team
5. **Begin** Phase 1: Foundation
6. **Schedule** regular review meetings
7. **Track** progress against milestones

---

**Last Updated:** 2026-01-05
**Document Version:** 1.0
