# Phase 6: Synchronization

## Overview

Synchronization is the bridge between offline field work and the server backend. This phase implements event sourcing, automatic sync with intelligent retry logic, background photo uploads, and survey completion workflows. All sync operations must be non-blocking and transparent to the operator.

## Components

### SyncEngine/
Main synchronization orchestrator managing event and photo uploads.

**Key Features:**
- Automatic sync trigger on create/update/delete
- Upload events in timestamp order
- Background photo upload queue
- Intelligent retry logic
- Sync state tracking
- Network availability detection

**Retry Logic:**
- Failed sync → retry every 30 seconds
- After 10 consecutive failures → retry every 5 minutes
- Continue indefinitely until successful
- No manual sync trigger

**Sync States:**
- **Syncing:** Upload in progress
- **Synced:** All changes uploaded
- **Failed:** Last sync attempt failed

**Key Files:**
- `SyncManager.swift`
- `EventUploader.swift`
- `PhotoUploader.swift`
- `SyncStatusTracker.swift`
- `RetryScheduler.swift`
- `ConflictResolver.swift` (future)

### EventSourcing/
Event log pattern for complete audit trail and sync.

**Event Types:**
- `INSTANCE_CREATED` - New asset instance
- `INSTANCE_UPDATED` - Instance parameters modified
- `INSTANCE_DELETED` - Instance removed
- `TYPE_CREATED` - New Type defined
- `TYPE_UPDATED` - Type parameters modified
- `PHOTO_ATTACHED` - Photo linked to Type or Instance
- `ROOM_NOTE_CREATED` - Room Note added
- `ROOM_NOTE_UPDATED` - Room Note modified
- `ROOM_NOTE_DELETED` - Room Note removed

**Event Structure:**
```json
{
  "event_id": "uuid-v7",
  "event_type": "INSTANCE_CREATED",
  "timestamp": "2025-12-15T14:30:00Z",
  "project_id": "uuid",
  "payload": {
    "instance_id": "uuid",
    "type_id": "uuid",
    "room_id": "uuid",
    "parameters": {...}
  },
  "device_id": "uuid",
  "operator_id": "uuid"
}
```

**Key Files:**
- `Event.swift` (from DataModels)
- `EventLogger.swift`
- `EventTypes.swift`
- `EventSerializer.swift`
- `EventCompactor.swift` (future)

### PhotoUploadQueue/
Background photo upload with retry and persistence.

**Key Features:**
- Background upload when app suspended
- Upload Type and Instance photos
- Track upload status per photo
- Retry failed uploads with backoff
- Update local status on success/failure
- Resume interrupted uploads
- Respect network conditions (WiFi vs cellular)

**Photo Upload States:**
- **Pending:** Queued for upload
- **Uploading:** Transfer in progress
- **Uploaded:** Successfully uploaded
- **Failed:** Upload failed, will retry

**Key Files:**
- `PhotoQueueManager.swift`
- `BackgroundUploadSession.swift`
- `PhotoUploadTask.swift`
- `UploadRetryPolicy.swift`
- `PhotoCompletionHandler.swift`

### SurveyCompletion/
Survey completion validation and project state management.

**Key Features:**
- Exit button with Pause/Complete options
- Validation: all rooms have ≥1 asset or Room Note
- Empty rooms report with filter shortcut
- "Slide to complete" confirmation
- Project state change to COMPLETED
- Read-only mode activation
- Final sync trigger

**Workflow:**
1. Operator taps Exit button (top-left)
2. Popup: "Pause Survey" or "Complete Survey"
3. **Pause:** Return to Projects page, can resume later
4. **Complete:**
   - Validate all rooms addressed
   - If incomplete: show empty rooms report + filter link
   - If complete: "Slide to complete" control
   - On slide: state → COMPLETED, read-only mode
   - Trigger final sync

**Key Files:**
- `SurveyCompletionValidator.swift`
- `ExitPopupView.swift`
- `EmptyRoomsReportView.swift`
- `SlideToCompleteControl.swift`
- `ReadOnlyModeActivator.swift`

## Synchronization Flow

### 1. Event Creation
```
User Action (create/update/delete)
    ↓
Event Logged Locally (UUIDv7, timestamp)
    ↓
Trigger Sync Attempt
```

### 2. Event Upload
```
Check Network Availability
    ↓
If Online:
    Upload Events in Order (oldest first)
    ↓
    Server Acknowledges
    ↓
    Mark Events as Synced
    ↓
    Update Sync Status: "Synced"

If Offline:
    Update Sync Status: "Failed"
    ↓
    Schedule Retry (30 seconds)
```

### 3. Photo Upload
```
Photo Captured → Queued (status: Pending)
    ↓
Background Upload Task Created
    ↓
Upload to Server
    ↓
Success: status → Uploaded
Failure: status → Failed, Schedule Retry
```

### 4. Retry Logic
```
Initial Failure
    ↓
Retry after 30 seconds (attempts 1-10)
    ↓
If still failing after 10 attempts:
    Retry every 5 minutes indefinitely
    ↓
Continue until Success
```

## Event Sourcing Benefits

1. **Complete Audit Trail:** Every change tracked with timestamp and operator
2. **Offline-First:** Changes recorded locally, sync when possible
3. **Conflict Detection:** Future capability to detect and resolve conflicts
4. **Undo Support:** Future capability to revert changes
5. **Data Recovery:** Can rebuild state from event log
6. **Debugging:** Clear history of all operations

## Network Considerations

### Bandwidth Management
- Events are small JSON (typically <1KB each)
- Photos are larger (typically 100-500KB after compression)
- Upload photos in background, events immediately

### Connection Types
- **WiFi:** Upload everything immediately
- **Cellular:** Upload events immediately, defer photos (future: user preference)
- **Offline:** Queue everything, retry when online

### Battery Impact
- Background uploads use energy-efficient APIs
- Batch uploads when possible
- Respect Low Power Mode (future)

## Dependencies

- **Phase 1:** DataModels, LocalStorage, NetworkLayer, CoreServices
- **Phase 2:** CommonComponents
- **Phase 5:** SurveyReporting (for completion workflow)
- **External:** Network framework, BackgroundTasks framework, Combine

## Success Criteria

- [ ] Events logged for all changes
- [ ] Events uploaded in correct order
- [ ] Photos uploaded in background
- [ ] Retry logic works correctly (30s → 5min)
- [ ] Sync status accurate and visible
- [ ] Survey completion validates all rooms
- [ ] Empty rooms report shows correct list
- [ ] Slide to complete activates read-only mode
- [ ] Final sync triggered on completion
- [ ] Background uploads resume after app restart
- [ ] Network state changes trigger appropriate actions
- [ ] 80%+ unit test coverage

## Development Timeline

**Estimated Duration:** 4 weeks (Sprints 12-13)

**Week 23:** EventSourcing implementation
**Week 24:** PhotoUploadQueue with background tasks
**Week 25:** SyncEngine with retry logic
**Week 26:** SurveyCompletion workflow + Testing

## Testing Requirements

- Unit tests for event logging and serialization
- Integration tests for sync flow
- Network condition simulation tests
- Retry logic tests
- Background upload tests
- Survey completion validation tests
- State transition tests
- Offline/online scenario tests

## UI/UX Guidelines

### Sync Status Indicator
- **Position:** Top-right on floorplan
- **States:**
  - Syncing: Animated spinner
  - Synced: Checkmark icon
  - Failed: Warning icon
- **Interaction:** Tap for detailed status message

### Status Messages
- **Syncing:** "Uploading changes... (3 events, 2 photos)"
- **Synced:** "All changes synced"
- **Failed:** "Sync failed - will retry in 30 seconds"
- **After 10 failures:** "Sync failed - will retry in 5 minutes"

### Exit Popup
- **Title:** "Exit Survey"
- **Options:**
  - "Pause Survey" (secondary button)
  - "Complete Survey" (primary button)
  - "Cancel" (text button)

### Empty Rooms Report
- **Title:** "Incomplete Survey"
- **Message:** "The following rooms do not have assets or room notes:"
- **List:** Room numbers with (+) buttons
- **Action:** "View Empty Rooms" → Opens Survey Report filtered

### Slide to Complete
- **Message:** "Survey complete! All rooms addressed."
- **Control:** iOS-style slide to confirm
- **After slide:** Loading indicator → "Survey completed" → Return to Projects

## Common Pitfalls

- Don't upload events out of order
- Don't block UI during sync
- Don't retry too aggressively (battery drain)
- Don't lose queued changes on app restart
- Don't allow completion with empty rooms
- Don't forget to trigger final sync on completion
- Don't allow editing after completion
- Don't stop retrying after failures

## Monitoring and Debugging

### Event Log Inspection
- Ability to view local event queue
- See which events are pending upload
- Check event ordering

### Photo Queue Inspection
- View photo upload status
- See pending/failed uploads
- Retry failed photos manually (debug only)

### Sync History
- Log of all sync attempts
- Success/failure with timestamps
- Error messages for failures

### Developer Tools (Debug Only)
- Force sync trigger
- Clear sync queue
- Simulate network conditions
- View event payload

## Notes

- Sync must be completely transparent to operators
- Never lose data, even if sync fails indefinitely
- Event ordering is critical for data integrity
- Photo uploads can be deferred, events cannot
- UUIDv7 ensures events are time-sortable
- Background uploads must handle app termination gracefully
- Survey completion is a one-way state change
- Read-only mode prevents accidental edits after completion
