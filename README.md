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

**Note:** You need a backend server running on `localhost:3001` for the test to succeed.

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
