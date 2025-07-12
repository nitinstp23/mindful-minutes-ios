# Mindful Minutes iOS

A native iOS meditation tracking app built with SwiftUI, featuring elegant design and comprehensive progress analytics.

## 📱 Features

### ✅ Phase 1 & 2 Completed
- **Dashboard**: Dynamic greetings, today's progress, weekly goals, recent sessions
- **Progress Analytics**: Interactive charts, streak tracking, milestone achievements
- **Session Management**: Advanced filtering, search, detailed session views
- **Settings**: Comprehensive preferences, goals, notifications, and accessibility options
- **Design System**: Consistent emerald theme with reusable components

### 🔄 Coming Soon (Phase 3)
- Real-time session tracking and timer
- SwiftData persistence layer
- Backend API integration
- iCloud sync capabilities

## 🎨 Design Language

- **Colors**: Emerald (#10b981) and Teal (#14b8a6) with light backgrounds
- **Typography**: SF Pro Display (headings) and SF Pro Text (body)
- **Style**: Elegant minimalism with functional design
- **UI Elements**: Rounded corners, subtle shadows, generous whitespace

## 🛠 Requirements

- **Xcode**: 15.0+ (iOS 17.0+ required for SwiftData)
- **iOS Deployment Target**: 17.0+
- **Swift**: 5.9+
- **Frameworks**: SwiftUI, SwiftData, UserNotifications

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/nitinstp23/mindful-minutes-ios.git
cd mindful-minutes-ios
```

### 2. Open in Xcode
```bash
open mindful-minutes/mindful-minutes.xcodeproj
```

### 3. Build and Run
1. Select your target device or simulator (iOS 17.0+)
2. Press `⌘ + R` to build and run
3. The app will launch with sample data

## 📁 Project Structure

```
mindful-minutes-ios/
├── mindful-minutes/
│   ├── mindful-minutes/
│   │   ├── mindful_minutesApp.swift     # App entry point
│   │   ├── ContentView.swift            # Tab navigation
│   │   ├── HomeView.swift               # Dashboard screen
│   │   ├── ProgressView.swift           # Analytics screen
│   │   ├── SessionsView.swift           # Session management
│   │   ├── SessionDetailView.swift      # Session details
│   │   ├── SettingsView.swift           # App settings
│   │   ├── DesignSystem.swift           # Reusable components
│   │   ├── WeeklyChart.swift            # Chart component
│   │   ├── MonthlyCalendar.swift        # Calendar heatmap
│   │   └── Assets.xcassets/             # App assets
│   ├── mindful-minutesTests/            # Unit tests
│   └── mindful-minutesUITests/          # UI tests
├── PROJECT_PLAN.md                      # Development roadmap
└── README.md                            # This file
```

## 🏗 Architecture

### SwiftUI + SwiftData
- **UI Framework**: SwiftUI for declarative, modern interface
- **Data Layer**: SwiftData for local persistence (Phase 3)
- **Navigation**: Tab-based with NavigationView hierarchy
- **State Management**: @State and @StateObject patterns

### Design Patterns
- **Component-Based**: Reusable MindfulCard, MindfulButton components
- **Modular Views**: Each screen broken into focused sections
- **Data-Driven**: Chart components accept data models
- **Responsive**: Adapts to different screen sizes

## 🎯 Key Components

### Custom UI Components
- **MindfulCard**: Consistent card container with shadow and padding
- **MindfulButton**: Primary/secondary button styles with emerald theme
- **MindfulFooter**: Branded footer with divider
- **WeeklyChart**: Interactive bar chart for weekly progress
- **MonthlyCalendar**: GitHub-style activity heatmap

### Screen Features
- **HomeView**: Time-based greetings, progress cards, recent sessions
- **ProgressView**: Charts, statistics, milestones, timeframe switching
- **SessionsView**: Filtering, search, grouped lists, detail navigation
- **SettingsView**: 8 organized sections with interactive controls

## 🧪 Testing

### Run Unit Tests
```bash
⌘ + U
```

### Run UI Tests
```bash
⌘ + Ctrl + U
```

## 🚨 Troubleshooting

### Build Issues
- Ensure Xcode 15.0+ is installed
- Check iOS deployment target is 17.0+
- Clean build folder: `⌘ + Shift + K`

### Runtime Warnings
- ProgressView warnings: Fixed with value clamping
- ForEach ID conflicts: Fixed with enumerated arrays
- Missing previews: Ensure preview device supports iOS 17.0+

## 📋 Development Status

### ✅ Phase 1: Foundation & Navigation
- [x] Xcode project setup with SwiftUI
- [x] Tab-based navigation structure
- [x] Basic screens with sample data
- [x] Design system and color scheme

### ✅ Phase 2: Core Screens
- [x] Enhanced dashboard with dynamic content
- [x] Interactive progress charts and analytics
- [x] Professional session management system
- [x] Comprehensive settings interface

### 🔄 Phase 3: Data & Functionality (Next)
- [ ] SwiftData models and persistence
- [ ] Session tracking and timer functionality
- [ ] Real progress calculations
- [ ] Backend API integration

### 📅 Phase 4: Polish & iOS Features (Future)
- [ ] Animations and haptic feedback
- [ ] Accessibility improvements
- [ ] Widget support
- [ ] Shortcuts integration

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏢 About

**Made with ❤️ by MindfulLabs**

Part of the Mindful Minutes ecosystem:
- [Web App](https://github.com/nitinstp23/mindful-minutes-web) - Next.js web application
- [API](https://github.com/nitinstp23/mindful-minutes-api) - Go backend service
- [iOS App](https://github.com/nitinstp23/mindful-minutes-ios) - Native iOS application

---

For questions or support, please open an issue or contact the development team.