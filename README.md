# MH Assistant

A cross-platform mental health assessment and session management tool for counselors and psychologists. Built with Flutter.

Administer standardized assessments (DASS-21, SRQ-20, C-SSRS) in Bengali, manage client sessions with GPS location tracking, and collaborate with other counselors — all in one app.

## Features

- **Client Management** — Register clients with anonymized aliases, assign multiple counselors, view session and assessment history.
- **Session Management** — Schedule sessions with date/time, track status (scheduled/completed/cancelled), add follow-up dates, take notes, and assign counselors.
- **GPS Location Recording** — Record session location using GPS with accuracy filtering (≤10m), view on an interactive OpenStreetMap map with zoom controls, and open the location in Google Maps.
- **Standardized Assessments** — Administer validated mental health screening tools entirely in Bengali:
  - **DASS-21** — 21-item Depression, Anxiety & Stress Scale with severity thresholds (Normal to Extremely Severe).
  - **SRQ-20** — WHO Self-Reporting Questionnaire (20 yes/no items, threshold ≥8).
  - **C-SSRS** — Columbia Suicide Severity Rating Scale with pattern-based risk classification (No Risk to High Risk).
- **Assessment Runner** — Question-by-question UI with progress bar, skip-logic for conditional questions, and scroll-to-next-unanswered.
- **Results & Scoring** — Detailed severity visualizations with Bengali interpretations and clinical recommendations.
- **Dashboard** — Quick stats, today's schedule, recent clients, and a high-risk alert banner for unreviewed severe assessments.
- **Counselor Directory** — Browse all counselors in the organization with tap-to-call and tap-to-email.
- **Responsive UI** — Adapts between mobile (bottom navigation) and desktop (sidebar) layouts. Theme switching (light/dark/system) persisted across sessions.
- **MHPSS Reference** — Built-in educational content covering Mental Health & Psychosocial Support, Psychological First Aid, and counselling basics.
- **Privacy-First** — Anonymized client aliases, comprehensive privacy policy, and secure Firebase authentication.

## Screenshots

| Dashboard | Client Sessions | Assessment Runner |
|---|---|---|
| *(screenshot)* | *(screenshot)* | *(screenshot)* |

| Session Location | Assessment Results | Counselor Directory |
|---|---|---|
| *(screenshot)* | *(screenshot)* | *(screenshot)* |

## Tech Stack

| Category | Technology |
|---|---|
| **Framework** | Flutter 3.x (Dart SDK ^3.11.0) |
| **State Management** | Riverpod 3.3.1 |
| **Routing** | go_router 17.x |
| **Backend** | Firebase Auth, Cloud Firestore |
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
│   ├── routing/             # GoRouter config + navigation shell
│   └── theme/               # Light/dark themes + persistence
└── features/
    ├── assessment_engine/   # Assessment models, scoring, runner UI
    ├── auth/                # Firebase auth, registration, organization
    ├── clients/             # Client/session CRUD, detail screens
    ├── contacts/            # Counselor directory
    ├── dashboard/           # Home screen with stats & alerts
    └── settings/            # Profile, theme, MHPPS, privacy
```

Each feature follows a consistent internal structure:

- `data/` — Repositories (Firestore CRUD, local asset loading)
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
│       ├── assessment_engine/
│       ├── auth/
│       ├── clients/
│       ├── contacts/
│       ├── dashboard/
│       └── settings/
└── pubspec.yaml
```

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
