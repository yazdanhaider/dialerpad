# Dialerpad App

A feature-rich phone dialer application built with Flutter, implementing modern UI/UX principles and comprehensive calling features.

## Features

### Core Features
- ✅ Modern Dialpad UI
  - Custom numeric keypad with letter indicators
  - International dialing code selector
  - Real-time number formatting
  - Haptic feedback
  - Auto-scrolling number display

- ✅ Call Management
  - Make phone calls
  - Call state detection (Incoming/Outgoing/Connected/Disconnected)
  - Active call display with duration
  - Call history with detailed logs
  - Platform-specific handling (Android/iOS)

- ✅ Contact Management
  - View and manage contacts
  - Add new contacts
  - Search contacts (name/number)
  - Contact details view
  - Add number to existing contact
  - Google Contacts sync

- ✅ Call History
  - Comprehensive call logs
  - Categorized by date (Today/Yesterday/Earlier)
  - Filter by call type (Missed/Incoming/Outgoing)
  - Detailed call information
  - Quick actions (Call back, Add to contacts)

### Additional Features
- ✅ Number Blocking
  - Block/unblock numbers
  - Blocked numbers list
  - Block from call logs/contacts
  - Block unknown numbers

- ✅ UI/UX Features
  - Dark mode support
  - Modern Material Design
  - Smooth animations
  - Loading states with shimmer effects
  - Responsive layout
  - Platform-specific adaptations

### Technical Features
- ✅ State Management
  - GetX implementation
  - Reactive programming
  - Efficient state updates

- ✅ Permission Handling
  - Runtime permissions
  - Graceful permission management
  - User-friendly permission requests

- ✅ Error Handling
  - Comprehensive error messages
  - Fallback behaviors
  - Platform-specific error handling

## Technical Details

### Architecture
- Clean folder structure following modular approach
- GetX pattern implementation
- Service-based architecture
- Platform-specific implementations

### Key Packages
- `get`: State management and routing
- `phone_state`: Call state detection
- `contacts_service`: Contact management
- `call_log`: Call history management
- `google_sign_in`: Google integration
- `permission_handler`: Permission management

### Platform Support
- Android: API 24+ (Android 7.0 and above)
- iOS: Basic support (limited features due to platform restrictions)

## Installation

1. **Clone the Repository:**
    ```bash
    git clone https://github.com/yazdanhaider/dialerpad
    ```

2. **Configure API Keys:**
    - Copy `lib/app/config/api_keys.template.dart` to `lib/app/config/api_keys.dart`
    - Add your Google API credentials

3. **Install Dependencies:**
    ```bash
    flutter pub get
    ```

4. **Run the App:**
    ```bash
    flutter run
    ```

## Code Structure

- `lib/`: Contains the main codebase
  - `app/`: Core application code
    - `common/`: Shared components
      - `widgets/`: Reusable UI components
      - `values/`: App constants, colors, styles
    - `modules/`: Feature modules
      - `dialpad/`: Dialer functionality
      - `contacts/`: Contact management
      - `history/`: Call logs and history
      - `blocked/`: Number blocking feature
    - `services/`: Core services
      - Call handling
      - Contact management
      - Theme management
      - Google integration
    - `routes/`: App navigation
    - `config/`: App configuration
  - `models/`: Data models
  - `main.dart`: Application entry point

## Permissions Required
- Phone State
- Call Log Access
- Contacts Access
- Phone Call Permission

## Contributing
[Contributing guidelines]

## License
[License information]
