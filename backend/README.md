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

### Local Emulators

```bash
npm run dev
```

Environment variables come from `.env` (copy `.env.example`).

## Scripts

- `npm run build`: Compile TypeScript to `lib/`
- `npm run lint`: ESLint checks
- `npm run test`: Jest unit tests
- `npm run dev`: Firebase emulators (functions, firestore, auth, pubsub)

## Deployment

```bash
firebase use <development|staging|production>
firebase deploy --only functions
```

Refer to `doc/backend_sprint_plan.md` for the detailed roadmap.
