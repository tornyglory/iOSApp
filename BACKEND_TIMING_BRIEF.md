# Backend Implementation Brief: Session Timing Feature

## Overview
This brief outlines the backend changes required to implement session timing functionality for the Lawn Bowls Training app. The Swift client has been updated to support timing features and expects the following backend implementations.

## Database Schema Changes

### 1. Sessions Table Updates
Add the following columns to the `sessions` table:

```sql
ALTER TABLE sessions ADD COLUMN started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE sessions ADD COLUMN ended_at TIMESTAMP NULL;
ALTER TABLE sessions ADD COLUMN duration_seconds INTEGER NULL;
ALTER TABLE sessions ADD COLUMN is_active BOOLEAN DEFAULT true;
```

### 2. Optional: Shots Table Enhancement
For more granular tracking, consider adding shot-level timing:

```sql
ALTER TABLE shots ADD COLUMN recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
```

## API Endpoint Changes

### 1. Update Existing Endpoints

#### POST /sessions
- **Change**: Automatically set `started_at` to current timestamp
- **Change**: Set `is_active` to `true` by default
- **Response**: Include timing fields in response

```json
{
  "status": "success",
  "message": "Training session created successfully",
  "session": {
    "id": 123,
    "player_id": 456,
    "started_at": "2025-01-12T10:00:00.000Z",
    "ended_at": null,
    "duration_seconds": null,
    "is_active": true,
    // ... other existing fields
  }
}
```

#### GET /sessions & GET /sessions/{id}
- **Change**: Include timing fields in all session responses
- **Response**: Add computed duration for display

### 2. New Required Endpoints

#### POST /sessions/{id}/end
End a training session and calculate duration.

**Request Body:**
```json
{
  "ended_at": "2025-01-12T11:30:00.000Z"
}
```

**Logic:**
1. Validate session exists and is active
2. Set `ended_at` to provided timestamp
3. Calculate `duration_seconds` = ended_at - started_at
4. Set `is_active` to `false`
5. Return updated session

**Response:**
```json
{
  "status": "success", 
  "message": "Session ended successfully",
  "session": {
    "id": 123,
    "started_at": "2025-01-12T10:00:00.000Z",
    "ended_at": "2025-01-12T11:30:00.000Z",
    "duration_seconds": 5400,
    "is_active": false,
    // ... other fields
  }
}
```

#### GET /sessions/active
Get the currently active session for a user.

**Logic:**
1. Find session where `is_active = true` for current user
2. Return session or 404 if none active

**Response (if active session exists):**
```json
{
  "status": "success",
  "session": {
    "id": 123,
    "started_at": "2025-01-12T10:00:00.000Z",
    "ended_at": null,
    "duration_seconds": null,
    "is_active": true,
    // ... other fields
  }
}
```

**Response (if no active session):**
```json
{
  "status": "error",
  "message": "No active session found"
}
```
*Return HTTP 404 status code*

## Business Logic Requirements

### 1. Session State Management
- Only one active session per user at a time
- When creating a new session, end any existing active sessions
- Validate session ownership for all operations

### 2. Duration Calculation
- Calculate duration in seconds for consistent storage
- Handle timezone considerations (store UTC, display local)
- Gracefully handle edge cases (clock changes, etc.)

### 3. Data Validation
- `ended_at` must be after `started_at`
- Cannot end a session that's already ended
- Session must exist and belong to authenticated user

## Database Migration Script

```sql
-- Add timing columns to sessions table
ALTER TABLE sessions 
ADD COLUMN started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN ended_at TIMESTAMP NULL,
ADD COLUMN duration_seconds INTEGER NULL,
ADD COLUMN is_active BOOLEAN DEFAULT true;

-- Update existing sessions to have started_at = created_at
UPDATE sessions 
SET started_at = created_at, 
    is_active = false 
WHERE started_at IS NULL;

-- Add index for performance
CREATE INDEX idx_sessions_active ON sessions(player_id, is_active);
CREATE INDEX idx_sessions_started_at ON sessions(started_at);

-- Optional: Add shot timing
ALTER TABLE shots ADD COLUMN recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
UPDATE shots SET recorded_at = created_at WHERE recorded_at IS NULL;
```

## Client Integration Points

The Swift client has been updated with:

1. **Models**: `TrainingSession` now includes `startedAt`, `endedAt`, `durationSeconds`, `isActive`
2. **API Methods**: `endSession()` and `getActiveSession()` methods added
3. **UI Features**: Live timer display, session duration in summary
4. **Request Model**: `EndSessionRequest` with `ended_at` field

## Testing Considerations

### Unit Tests
- Duration calculation accuracy
- Timezone handling
- Edge cases (same start/end time, etc.)

### Integration Tests  
- End-to-end session timing flow
- Multiple concurrent sessions per user
- Session state transitions

### Performance Tests
- Query performance with timing indexes
- Large dataset duration calculations

## Optional Future Enhancements

1. **Session Pause/Resume**: Add endpoints for pausing and resuming sessions
2. **Analytics**: Session duration analytics and insights
3. **Notifications**: Remind users of long-running sessions
4. **Auto-end**: Automatically end inactive sessions after timeout

## Implementation Priority

**Phase 1 (Required)**:
- Database schema updates
- POST /sessions/{id}/end endpoint
- GET /sessions/active endpoint
- Update existing endpoints to include timing fields

**Phase 2 (Optional)**:
- Shot-level timing
- Advanced analytics
- Session management features

This implementation will provide a complete session timing experience matching the Swift client expectations.