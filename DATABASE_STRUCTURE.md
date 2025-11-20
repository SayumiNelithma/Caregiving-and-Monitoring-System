# Database Structure & Backend Migration Guide

## Current Implementation (Firestore)

The application currently uses **Firebase Firestore** to store data. All data is saved in the cloud and persists across app sessions.

### Database Collections

#### 1. **journal_entries** Collection
Stores voice and text journal entries for users.

**Document Structure:**
```json
{
  "id": "auto-generated-doc-id",
  "userId": "user-uid",
  "text": "Journal entry content",
  "timestamp": "2024-01-15T10:30:00Z",
  "type": "voice" | "text"
}
```

**Location in Code:**
- Model: `lib/models/journal_entry_model.dart`
- Service: `lib/services/journal_service.dart`
- Page: `lib/pages/elder/voice_chatbot_page.dart`

---

#### 2. **users** Collection (Already Exists)
Stores user profile information.

**Document Structure:**
```json
{
  "uid": "user-uid",
  "email": "user@example.com",
  "name": "User Name",
  "role": "elder" | "caregiver" | "familyMember" | "admin",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

---

### Future Collections (To Be Implemented)

#### 3. **daily_routines** Collection
Will store daily routine schedules and completion status.

**Proposed Document Structure:**
```json
{
  "id": "auto-generated-doc-id",
  "userId": "user-uid",
  "date": "2024-01-15",
  "routines": [
    {
      "time": "08:00 AM",
      "activity": "Morning Exercise",
      "description": "Light stretching",
      "completed": false,
      "icon": "fitness_center"
    }
  ],
  "createdAt": "2024-01-15T00:00:00Z"
}
```

#### 4. **meal_plans** Collection
Will store AI-generated meal plans.

**Proposed Document Structure:**
```json
{
  "id": "auto-generated-doc-id",
  "userId": "user-uid",
  "date": "2024-01-15",
  "dayOfWeek": 0-6,
  "meals": {
    "breakfast": [
      {
        "name": "Oatmeal with fruits",
        "calories": 300
      }
    ],
    "lunch": [...],
    "dinner": [...],
    "snacks": [...]
  },
  "totalCalories": 1500,
  "createdAt": "2024-01-15T00:00:00Z"
}
```

#### 5. **therapy_sessions** Collection
Will store therapy session conversations.

**Proposed Document Structure:**
```json
{
  "id": "auto-generated-doc-id",
  "userId": "user-uid",
  "messages": [
    {
      "text": "User message",
      "isUser": true,
      "timestamp": "2024-01-15T10:30:00Z"
    },
    {
      "text": "AI response",
      "isUser": false,
      "timestamp": "2024-01-15T10:30:05Z"
    }
  ],
  "sessionStart": "2024-01-15T10:30:00Z",
  "sessionEnd": "2024-01-15T10:45:00Z"
}
```

---

## Migration to Python Backend

### Option 1: REST API with Python (Flask/FastAPI)

#### Backend Structure
```
backend/
├── app.py (or main.py)
├── models/
│   ├── journal_entry.py
│   ├── daily_routine.py
│   ├── meal_plan.py
│   └── therapy_session.py
├── routes/
│   ├── journal_routes.py
│   ├── routine_routes.py
│   ├── meal_routes.py
│   └── therapy_routes.py
├── database/
│   └── db.py (SQLAlchemy/PostgreSQL/MySQL)
└── requirements.txt
```

#### Example API Endpoints

**Journal Entries:**
- `POST /api/journal/entries` - Create new entry
- `GET /api/journal/entries?userId={uid}` - Get all entries for user
- `DELETE /api/journal/entries/{entryId}` - Delete entry

**Daily Routines:**
- `GET /api/routines?userId={uid}&date={date}` - Get routine for date
- `POST /api/routines` - Create/update routine
- `PATCH /api/routines/{routineId}/complete` - Mark activity as complete

**Meal Plans:**
- `GET /api/meals?userId={uid}&date={date}` - Get meal plan
- `POST /api/meals/generate` - Generate AI meal plan
- `PUT /api/meals/{mealId}` - Update meal plan

**Therapy Sessions:**
- `POST /api/therapy/sessions` - Start new session
- `POST /api/therapy/sessions/{sessionId}/messages` - Add message
- `GET /api/therapy/sessions?userId={uid}` - Get session history

#### Database Schema (SQL)

```sql
-- Journal Entries
CREATE TABLE journal_entries (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    text TEXT NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    type VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Daily Routines
CREATE TABLE daily_routines (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, date)
);

CREATE TABLE routine_activities (
    id VARCHAR(255) PRIMARY KEY,
    routine_id VARCHAR(255) NOT NULL,
    time VARCHAR(20) NOT NULL,
    activity VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    icon VARCHAR(50),
    FOREIGN KEY (routine_id) REFERENCES daily_routines(id)
);

-- Meal Plans
CREATE TABLE meal_plans (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    date DATE NOT NULL,
    day_of_week INT NOT NULL,
    total_calories INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, date)
);

CREATE TABLE meal_items (
    id VARCHAR(255) PRIMARY KEY,
    meal_plan_id VARCHAR(255) NOT NULL,
    meal_type VARCHAR(20) NOT NULL, -- breakfast, lunch, dinner, snacks
    name VARCHAR(255) NOT NULL,
    calories INT NOT NULL,
    icon VARCHAR(50),
    FOREIGN KEY (meal_plan_id) REFERENCES meal_plans(id)
);

-- Therapy Sessions
CREATE TABLE therapy_sessions (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    session_start TIMESTAMP NOT NULL,
    session_end TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE therapy_messages (
    id VARCHAR(255) PRIMARY KEY,
    session_id VARCHAR(255) NOT NULL,
    text TEXT NOT NULL,
    is_user BOOLEAN NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    FOREIGN KEY (session_id) REFERENCES therapy_sessions(id)
);
```

### Option 2: Keep Firestore, Add Python Microservices

You can keep Firestore for data storage and use Python for:
- **AI/ML Processing**: Meal plan generation, therapy responses
- **Data Analysis**: Journal sentiment analysis, routine completion analytics
- **Scheduled Tasks**: Daily routine reminders, meal plan generation

**Architecture:**
```
Flutter App → Firestore (Data Storage)
           ↓
           Python Services (AI Processing)
           ↓
           Firestore (Store AI-generated content)
```

---

## Migration Steps

### Step 1: Create Python Backend API
1. Set up Flask/FastAPI server
2. Create database models matching Firestore structure
3. Implement REST API endpoints
4. Add authentication (JWT tokens using Firebase Auth)

### Step 2: Update Flutter App
1. Create API service classes (similar to current Firestore services)
2. Replace Firestore calls with HTTP requests
3. Handle authentication tokens
4. Add error handling and retry logic

### Step 3: Data Migration
1. Export data from Firestore
2. Import to SQL database
3. Verify data integrity

### Example Flutter API Service

```dart
// lib/services/api_service.dart
class ApiService {
  final String baseUrl = 'https://your-python-backend.com/api';
  
  Future<List<JournalEntry>> getJournalEntries(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/journal/entries?userId=$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    // Parse and return
  }
  
  Future<void> saveJournalEntry(JournalEntry entry) async {
    await http.post(
      Uri.parse('$baseUrl/journal/entries'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(entry.toMap()),
    );
  }
}
```

---

## Current Status

✅ **Implemented:**
- Journal entries saved to Firestore (`journal_entries` collection)
- Data persists across app sessions
- Real-time updates available via Firestore streams

⏳ **To Be Implemented:**
- Daily routines persistence
- Meal plans persistence
- Therapy sessions persistence
- Python backend integration

---

## Notes

- All current data is stored in **Firestore** and will persist
- When migrating to Python backend, you can export Firestore data and import to SQL
- Consider using **Firebase Functions** as an intermediate step to call Python services
- Keep Firestore for real-time features, use Python for AI/ML processing

