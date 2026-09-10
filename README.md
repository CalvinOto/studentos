# StudentOS

A daily-life companion app designed for students to manage their schedules, tasks, finances, and profiles. The project is split into a NestJS backend and a Flutter mobile client.

## Project Structure

```text
studentos/
├── backend/     # NestJS API — auth, schedule, tasks, expenses, profile
└── mobile/      # Flutter app — mobile client
```

## Features

*   **Schedule:** Manage classes and personal activities. Supports one-time, weekly, or monthly occurrences. Includes the ability to skip a single occurrence (like a holiday) without breaking the recurring pattern.
*   **Tasks:** Track assignments and to-dos with titles, categories, priorities, due dates, and pending/done statuses.
*   **Finance:** Log expenses in Rupiah, set a monthly budget, and track spending by category.
*   **Profile:** Store personal details (name, university, major, year), toggle light/dark themes, and manage user sessions.

## Prerequisites

*   **Backend:** Node.js 18+ and npm
*   **Mobile:** Flutter SDK 3.3+
*   **Environment:** An emulator/simulator or a physical phone connected via USB

---

## Getting Started

### 1. Start the Backend
The API must be running before you launch the mobile app.

```bash
cd backend
npm install
cp .env.example .env
```

Open `.env` and set `JWT_SECRET` to your own secure, random string. Then, start the server:

```bash
npm run start:dev
```
*You should see: `StudentOS API running on http://localhost:3000`*

### 2. Run the Mobile App

```bash
cd mobile
flutter pub get
flutter run
```

### 3. First Launch
Because you are starting with an empty database, tap **"Create one"** on the login screen to register your first account.

---

## Database

The backend uses **SQLite** via a single, automatically generated file (`backend/studentos.sqlite`). There is no need to install a separate database server, making it perfect for personal use. 

*Note: TypeORM is currently configured with `synchronize: true` to auto-update the schema on startup. This is convenient for rapid development, but you should switch to proper migrations before storing critical production data.*

---

## API Reference

All routes except `/auth/*` require a `Bearer` token (obtained from login/register) in the Authorization header.

### Authentication
```http
POST   /auth/register    { email, password, name } -> { accessToken }
POST   /auth/login       { email, password }       -> { accessToken }
```

### Profile
```http
GET    /profile
PATCH  /profile          { name?, university?, major?, year?, monthlyBudget?, themeMode? }
```

### Schedule (Classes/Activities)
```http
GET    /classes
POST   /classes          { subject, kind, type, day, dayOfMonth, date?, start, end, location?, color, skipDates? }
PATCH  /classes/:id
DELETE /classes/:id
```

### Tasks
```http
GET    /tasks
POST   /tasks            { title, category?, priority?, dueDate, status? }
PATCH  /tasks/:id
PATCH  /tasks/:id/toggle (flips pending <-> done)
DELETE /tasks/:id
```

### Finances
```http
GET    /expenses
POST   /expenses         { amount, category?, date, note? }
PATCH  /expenses/:id
DELETE /expenses/:id
```

---

## Others

What isn't built yet:

*   **Offline Support:** No offline queueing. A failed request (due to a lack of internet) is currently lost and not retried later.
*   **Account Recovery:** No "forgot password" flow.
*   **Multi-User Hardening:** The app is currently optimized for a single personal user. Scaling for multiple concurrent users will require rate limiting, email verification, and proper database migrations.