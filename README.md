# MH Assistant

**🌐 [mhassistant.web.app](https://mhassistant.web.app)**

A cross-platform mental health assessment and session management tool for counselors and psychologists. Built with Flutter.

Administer standardized assessments (DASS-21, SRQ-20, C-SSRS) in Bengali, manage client sessions with GPS location tracking, and collaborate with other counselors — all in one app.

## Features

### Main App (Counselor)

- **Client Management** — Register clients with anonymized aliases, assign multiple counselors, view session and assessment history.
- **Session Management** — Schedule sessions with date/time, track status (scheduled/completed/cancelled), add follow-up dates, take notes, and assign counselors. Includes GPS location recording.
- **Standardized Assessments** — Administer validated mental health screening tools entirely in Bengali:
  - **DASS-21** — 21-item Depression, Anxiety & Stress Scale with severity thresholds.
  - **SRQ-20** — WHO Self-Reporting Questionnaire (20 yes/no items, threshold ≥8).
  - **C-SSRS** — Columbia Suicide Severity Rating Scale with pattern-based risk classification.
- **Dashboard** — Quick stats, today's schedule, recent clients, and a high-risk alert banner for unreviewed severe assessments.
- **Counselor Directory** — Browse all counselors in the organization with tap-to-call and tap-to-email.
- **Responsive UI** — Adapts between mobile (bottom navigation) and desktop (sidebar) layouts. Theme switching (light/dark/system) persisted.
- **MHPSS Reference** — Built-in educational content covering Mental Health & Psychosocial Support.
- **Change Password** — Update password via Settings → Account.
- **Privacy-First** — Anonymized client aliases, comprehensive privacy policy, and secure Firebase authentication.

### Admin Panel (`/admin/*`)

- **Separate Auth System** — Admins authenticate via a dedicated `admins` Firestore collection (email + password), independent of counselor Firebase Auth.
- **Dashboard** — Org-wide stats (clients, counselors, sessions, assessments) with weekly/monthly breakdowns.
- **Counselors** — Full CRUD: create counselor accounts with temporary passwords, edit details, delete accounts. Firebase Auth accounts created via Identity Toolkit REST API (no auto-sign-in).
- **Clients** — View all clients in the organization with search and filtering.
- **Assessments & Sessions** — View all assessments and sessions org-wide.
- **Admins** — Manage system admins grouped by organization. Supports `admin` (org-scoped) and `super_admin` (global) roles.
- **Organizations** — Create and manage organizations, each scoping its own counselors, clients, and data. Org-level admin management inside each organization detail.
- **Settings** — Admin profile card, change password, navigation back to main app, logout.
- **Role-Based Navigation** — Super admins see Admins, Organizations, Settings. Org admins see Dashboard, Counselors, Clients, Assessments, Sessions, Settings. Responsive sidebar on desktop, scrollable bottom nav on mobile.

## Screenshots

| Dashboard | Client Sessions | Assessment Runner |
|---|---|---|
| *(screenshot)* | *(screenshot)* | *(screenshot)* |

| Session Location | Assessment Results | Counselor Directory |
|---|---|---|
| *(screenshot)* | *(screenshot)* | *(screenshot)* |

| Admin Panel | Admin Settings | Organizations |
|---|---|---|
| *(screenshot)* | *(screenshot)* | *(screenshot)* |

## Tech Stack

| Category | Technology |
|---|---|
| **Framework** | Flutter 3.x (Dart SDK ^3.11.0) |
| **State Management** | Riverpod 3.3.1 |
| **Routing** | go_router 17.x |
| **Backend** | Firebase Auth, Cloud Firestore, Firebase Auth REST API |
| **Maps** | flutter_map (OpenStreetMap) + geolocator |
| **Charts** | fl_chart |
| **Typography** | Google Fonts (Outfit, Tiro Bangla) |
| **Codegen** | build_runner, freezed, riverpod_generator |
| **Platforms** | Android, iOS, Web |

## Architecture

Feature-first organization with Riverpod for dependency injection and state management:

```
lib/
├── core/                    # Cross-cutting: design system, routing, theme
│   ├── design_system/       # Colors, radii, spacing, breakpoints
│   ├── routing/             # GoRouter config + navigation shells
│   └── theme/               # Light/dark themes + persistence
└── features/
    ├── admin/               # Admin panel (screens, providers, widgets)
    ├── assessment_engine/   # Assessment models, scoring, runner UI
    ├── auth/                # Firebase auth, registration, admin auth
    ├── clients/             # Client/session CRUD, detail screens
    ├── contacts/            # Counselor directory
    ├── dashboard/           # Home screen with stats & alerts
    └── settings/            # Profile, theme, MHPSS, privacy, change password
```

Each feature follows a consistent internal structure:

- `data/` — Repositories (Firestore CRUD, REST API calls)
- `domain/` — Pure Dart models and business logic
- `presentation/` — Screens, widgets, and Riverpod providers

## Getting Started

### Prerequisites

- Flutter SDK ^3.11.0
- A Firebase project with Authentication (email/password) and Cloud Firestore enabled

### Setup

```bash
# Clone the repository
git clone https://github.com/your-org/mh_assistant.git
cd mh_assistant

# Install dependencies
flutter pub get

# Generate code (freezed, riverpod providers)
dart run build_runner build --delete-conflicting-outputs

# Configure Firebase
# 1. Create a Firebase project at https://console.firebase.google.com
# 2. Enable Authentication (Email/Password) and Cloud Firestore
# 3. Add your platform apps (Android, iOS, Web) in Firebase console
# 4. Download and place the config files:
#    - android/app/google-services.json
#    - ios/Runner/GoogleService-Info.plist (if building for iOS)
#    - lib/firebase_options.dart (run `flutterfire configure`)
```

### Run

```bash
flutter run
```

For web:

```bash
flutter run -d chrome
```

### Firebase Security Rules

Deploy these Firestore security rules for production:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Project Structure

```
mh_assistant/
├── assets/
│   └── data/
│       ├── dass21_bn.json    # DASS-21 assessment (Bengali)
│       ├── srq20_bn.json     # SRQ-20 assessment (Bengali)
│       └── cspt_bn.json      # C-SSRS assessment (Bengali)
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── design_system/app_design_system.dart
│   │   ├── routing/
│   │   │   ├── app_router.dart
│   │   │   └── main_navigation_shell.dart
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       └── theme_provider.dart
│   └── features/
│       ├── admin/            # Admin panel screens, providers, widgets
│       ├── assessment_engine/
│       ├── auth/
│       ├── clients/
│       ├── contacts/
│       ├── dashboard/
│       └── settings/
└── pubspec.yaml
```

## Admin Panel Setup

1. In the Firestore console, create an `admins` collection.
2. Add an admin document with fields: `name`, `email`, `password` (plaintext), `role` (`"admin"` or `"super_admin"`), `organizationId` (optional for super_admin).
3. For super_admin accounts, leave `organizationId` empty or omit it. They will have global access.
4. For org-level admin accounts, set `organizationId` to a valid organization document ID.
5. The `organizations` collection should have documents with `name` and optional `code` fields.

Navigate to `/admin/login` to sign in.

## Assessments

### DASS-21 (Depression, Anxiety & Stress Scale)

21 items scored on three 7-item sub-scales. Each sub-scale score is doubled for DASS-42 equivalence (max 42 per domain). Severity thresholds apply independently to Depression, Anxiety, and Stress.

### SRQ-20 (Self-Reporting Questionnaire)

WHO-developed 20-item yes/no screening tool for common mental disorders. A score of ≥8 indicates probable mental distress requiring further evaluation.

### C-SSRS (Columbia Suicide Severity Rating Scale)

7-question suicide risk screening with pattern-based scoring (not additive). Classifies risk as No Risk, Low, Moderate, or High based on the pattern of responses.

## License

Private — not licensed for public distribution.

---

Built for mental health professionals working in Bangladesh and Bengali-speaking communities.
