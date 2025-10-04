# EnglishBrain

English learning app with pattern-based training system.

## 📁 Project Structure

```
EnglishBrain/
├── README.md                    # This file
├── .gitignore                   # Git ignore rules
│
├── doc/                         # Documentation
│   ├── openapi.yaml            # OpenAPI 3.1 specification
│   ├── PRD.md                  # Product Requirements Document
│   └── UserFlow.md             # User flow and interaction design
│
├── sdk-swift/                   # Swift SDK (generated from OpenAPI)
│   ├── Package.swift           # Swift Package Manager manifest
│   ├── project.yml             # SDK project configuration
│   ├── README.md               # SDK documentation
│   ├── .gitignore              # SDK-specific ignores
│   │
│   ├── EnglishBrainAPI/        # SDK source code
│   │   ├── APIs/               # API client classes
│   │   │   ├── AttemptsAPI.swift
│   │   │   ├── LiveActivitiesAPI.swift
│   │   │   ├── NotificationsAPI.swift
│   │   │   ├── OnboardingAPI.swift
│   │   │   ├── PatternsAPI.swift
│   │   │   ├── PrivacyAPI.swift
│   │   │   ├── ReviewsAPI.swift
│   │   │   ├── SessionsAPI.swift
│   │   │   ├── TelemetryAPI.swift
│   │   │   └── UsersAPI.swift
│   │   │
│   │   ├── Models/             # Data models (78 models)
│   │   │   ├── Attempt.swift
│   │   │   ├── HomeSummary.swift
│   │   │   ├── Session.swift
│   │   │   ├── UserProfile.swift
│   │   │   └── ... (and more)
│   │   │
│   │   ├── Configuration.swift  # API configuration
│   │   ├── APIHelper.swift
│   │   └── ... (helper files)
│   │
│   └── docs/                    # Generated API documentation
│       └── *.md                 # Markdown docs for each API/Model
│
└── ios-app/                     # iOS Application
    ├── project.yml              # XcodeGen configuration
    ├── EnglishBrain.xcodeproj   # Xcode project
    │
    └── EnglishBrain/            # App source code
        ├── EnglishBrainApp.swift   # App entry point
        └── ContentView.swift       # Main view with API test UI

backend/                         # Firebase Functions backend
├── package.json                # Node project manifest (TypeScript)
├── firebase.json               # Emulator/runtime config
├── src/                        # Cloud Function sources
└── README.md                   # Backend setup guide
```

## 🚀 Getting Started

### Prerequisites

- macOS 13.0+
- Xcode 15.0+
- Swift 5.9+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (for project generation)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/ludia8888/EnglishBrain.git
   cd EnglishBrain
   ```

2. **Build the SDK** (optional, for verification)
   ```bash
   cd sdk-swift
   swift build
   cd ..
   ```

3. **Open the iOS app in Xcode**
   ```bash
   open ios-app/EnglishBrain.xcodeproj
   ```

4. **Build and run** (Cmd+R)
   - Select a simulator (iPhone 15 recommended)
   - The app will connect to `http://localhost:3001` by default

5. **Backend scaffolding**
   ```bash
   cd backend
   npm install
   npm run lint && npm run test && npm run build
   ```

   Use `npm run dev` to launch Firebase emulators after installing the Firebase CLI.

## 🔧 Development

### Regenerating the SDK

If you modify the OpenAPI spec (`doc/openapi.yaml`), regenerate the Swift SDK:

```bash
docker run --rm \
  -v "$PWD/doc/openapi.yaml:/openapi.yaml" \
  -v "$PWD/sdk-swift:/out" \
  openapitools/openapi-generator-cli:v7.5.0 \
  generate \
    -i /openapi.yaml \
    -g swift5 \
    -o /out \
    --additional-properties=projectName=EnglishBrainAPI,swiftPackagePath=EnglishBrainAPI
```

### Regenerating the Xcode Project

If you modify `ios-app/project.yml`:

```bash
cd ios-app
xcodegen generate
```

### API Base URL Configuration

The API base URL is configured in `ios-app/EnglishBrain/EnglishBrainApp.swift`:

```swift
EnglishBrainAPIAPI.basePath = "http://localhost:3001"  // Change as needed
```

**Environments:**
- **Local Development:** `http://localhost:3001`
- **Staging:** `https://api-staging.englishbrain.com`
- **Production:** `https://api.englishbrain.com`

### Mock Server (Prism)

Until the real backend is ready, you can serve mock responses directly from the OpenAPI contract using [Stoplight Prism](https://github.com/stoplightio/prism).

> Docker Desktop (or Colima) must be running before executing the command below.

```bash
docker run --rm \
  -v "$PWD/doc/openapi.yaml:/openapi.yaml:ro" \
  -p 3001:4010 \
  stoplight/prism:5 \
  mock /openapi.yaml --host 0.0.0.0
```

This maps Prism's default port (`4010`) to `localhost:3001`, so the app and SDK continue using the same base URL. Once Prism starts, you should see logs for each mocked request in the terminal.

**Optional checks**
- Visit `http://localhost:3001/users/me` in your browser or with `curl` to verify the mock server is responding.
- Use `CTRL+C` to stop the container when you're done.

#### Without Docker (Node.js only)

If Docker access is restricted, you can run Prism directly with Node.js:

```bash
npx @stoplight/prism mock doc/openapi.yaml --port 3001 --host 0.0.0.0
```

> The `--host 0.0.0.0` flag ensures the mock server listens on all interfaces so the iOS simulator (or other devices) can reach it.

For physical devices, replace the base URL in the app with your Mac's LAN IP (e.g. `http://192.168.x.x:3001`).

## 📦 SDK Overview

The Swift SDK is automatically generated from the OpenAPI specification and includes:

- **10 API clients** for different service endpoints
- **78 data models** representing all request/response types
- **Type-safe** Swift interfaces
- **Async/await** and completion handler support
- **Local package** integration (no external dependencies except AnyCodable)

### Example Usage

```swift
import EnglishBrainAPI

// Configure base URL (done in App init)
EnglishBrainAPIAPI.basePath = "http://localhost:3001"

// Call an API
UsersAPI.getHomeSummary { response, error in
    if let summary = response {
        print("Daily goal: \(summary.dailyGoal)")
    }
}
```

## 🧪 Testing

### API Connection Test

The app includes a built-in API test screen:

1. Run the app in simulator
2. Tap "Test API Connection" button
3. View the connection status

**Note:** You need a backend server running on `127.0.0.1:3001` for the test to succeed.

### Troubleshooting

#### "Connection refused" errors

If you see `Connection refused` errors:

1. **Check if Docker/Colima is running:**
   ```bash
   colima status
   # If broken or stopped, restart:
   colima delete
   colima start --cpu 4 --memory 8
   ```

2. **Verify Prism is running on port 3001:**
   ```bash
   curl http://127.0.0.1:3001/users/me/home
   # Should return a 401 response (auth required)
   ```

3. **If using `localhost` causes IPv6 connection attempts:**
   - The app uses `127.0.0.1:3001` to force IPv4 and avoid harmless IPv6 connection logs

#### 401 Unauthorized responses

Mock server returns `401` by default because the OpenAPI spec requires Firebase authentication. This is **expected behavior** for unauthenticated requests. To test without authentication:

- Remove `security` from specific endpoints in `doc/openapi.yaml`, or
- Add mock authentication headers to your SDK calls

## 📚 Documentation

- **Product Spec:** [doc/PRD.md](doc/PRD.md)
- **User Flows:** [doc/UserFlow.md](doc/UserFlow.md)
- **API Spec:** [doc/openapi.yaml](doc/openapi.yaml)
- **SDK Docs:** [sdk-swift/docs/](sdk-swift/docs/)

## 🛠️ Tech Stack

- **iOS App:** SwiftUI, Swift 5.9+
- **SDK:** Swift Package Manager
- **API Spec:** OpenAPI 3.1
- **Code Generation:** OpenAPI Generator
- **Project Generation:** XcodeGen

## 📝 Git Workflow

```bash
# Make changes
git add .
git commit -m "Description of changes"
git push origin main
```

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Regenerate SDK/project if needed
4. Commit and push
5. Create a pull request

## 📄 License

[Add your license here]

## 🔗 Links

- **GitHub:** https://github.com/ludia8888/EnglishBrain
- **OpenAPI Generator:** https://openapi-generator.tech/

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
