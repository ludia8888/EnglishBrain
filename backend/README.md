# English Brain Backend

Firebase Cloud Functions project powering the English Brain API surface.

## Prerequisites

- Node.js 18+
- Firebase CLI (`npm install -g firebase-tools`)
- Google Cloud project with Firestore/Functions enabled

## Setup

```bash
cd backend
npm install
npm run build
```

### Configure Firebase Authentication

The backend expects Firebase Authentication to be available with the following providers:

1. **Email / Password** – Required for internal QA accounts and customer password flows.
2. **Apple** – Required for iOS sign-in. Create a Service ID and upload the generated key in Firebase Console.
3. **Google** – Required for Android / Web sign-in. Supply the OAuth client ID/secret from Google Cloud Console.

Steps:

1. Select the desired project (`npm run firebase:use:dev`, `:staging`, or `:prod`).
2. Open [Firebase Console ▸ Authentication ▸ Sign-in method](https://console.firebase.google.com/) for the selected project.
3. Enable the three providers above and paste the required OAuth credentials.
4. For local emulator runs, create seed users via the emulator UI (`http://localhost:4000/auth`) or the Admin SDK once emulators are running.

> Tip: keep credentials in 1Password. Never commit them to source control.

### Local Emulators

```bash
npm run dev
```

Environment variables come from `.env` (copy `.env.example`).

### Contract Tests (Firestore/Auth Emulator)

```bash
firebase emulators:exec --only firestore,auth "npm run test:contract"
```

This spins up the Firestore and Auth emulators, seeds a sample `users/{uid}` document, signs in via the Auth emulator, and exercises `/users/me`, `/users/me/home`, `/users/me/widget-snapshot`, and `/level-tests`. The tests will skip automatically if emulator hosts are not detected.

### Firestore Security Rules

Firestore rules live in `firestore.rules`. After installing dev dependencies (`npm install`), run:

```bash
firebase emulators:exec --only firestore "npm test -- --runTestsByPath tests/firestore.rules.test.ts"
```

These tests use `@firebase/rules-unit-testing` to ensure users can only read/write their own profile documents. The rules are also wired into `firebase.json` so emulators and deployments pick them up automatically, and the suite will skip if the Firestore emulator host variables are not present.

### Firebase CLI

The project uses the locally installed CLI via `npx`:

- Login: `npm run firebase:login`
- Switch projects: `npm run firebase:use:dev` (or `:staging`, `:prod`)
- Start emulators: `npm run dev`
- Deploy functions: `npm run deploy`

> Note: Run `npm install` to download `firebase-tools` before using these commands.

## API Endpoints

### POST /level-tests

Submit level test results and receive a provisional level assignment.

**Request:**
```json
{
  "attempts": [
    {
      "itemId": "lesson-1",
      "selectedTokenIds": ["token-a", "token-b"],
      "timeSpentMs": 15000,
      "hintsUsed": 0
    }
  ],
  "startedAt": "2025-10-05T10:00:00Z",
  "completedAt": "2025-10-05T10:05:00Z"
}
```

**Requirements:**
- 10-15 attempts required
- Valid Firebase Auth token in `Authorization: Bearer <token>` header
- Each attempt must include `itemId`, `selectedTokenIds[]`, and `timeSpentMs`

**Response:**
```json
{
  "recommendedLevel": 2,
  "confidence": 0.75,
  "rationale": "Accuracy 75% across 10 attempts. Recommended level 2 computed from lesson difficulty.",
  "nextLessonId": "lesson-3",
  "unlocksReview": true,
  "needsSessionCalibration": true
}
```

**Side Effects:**
- Updates user profile: `provisionalLevel`, `flags.levelTestCompleted`
- Stores submission in `level_tests` collection

**Full API schema:** See [doc/openapi.yaml](../doc/openapi.yaml)

## Scripts

- `npm run build`: Compile TypeScript to `lib/`
- `npm run lint`: ESLint checks
- `npm run test`: Jest unit tests (fast, no emulator required)
- `npm run test:contract`: Emulator-backed contract tests (users + level-tests)
- `npm run dev`: Firebase emulators (functions, firestore, auth, pubsub)

## Deployment

```bash
firebase use <development|staging|production>
firebase deploy --only functions
```

Refer to `doc/backend_sprint_plan.md` for the detailed roadmap.
